//
//  HomeView.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 18/02/2022.
//

import SwiftUI
import NotificareKit
import NotificareScannablesKit

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @Preference(\.storeEnabled) private var storeEnabled: Bool
    
    init() {
        self._viewModel = StateObject(wrappedValue: HomeViewModel())
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 0) {
                    Text(String(localized: "home_welcome_title"))
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .padding(.top)
                    
                    Text(String(localized: "home_welcome_message"))
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .padding(.vertical)
                }
                
                if storeEnabled {
                    TopProductsView(products: viewModel.highlightedProducts)
                }
                
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(String(localized: "home_scan_title"), systemImage: "barcode.viewfinder")
                            .font(.headline)
                        
                        Text(String(localized: "home_scan_message"))
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 8)
                        
                        if Notificare.shared.scannables().canStartNfcScannableSession {
                            VStack(spacing: 0) {
                                Button(String(localized: "home_scan_nfc_button")) {
                                    Notificare.shared.scannables().startNfcScannableSession()
                                }
                                .buttonStyle(PrimaryButton())
                                
                                Button(String(localized: "home_scan_qr_button")) {
                                    guard let rootViewController = UIApplication.shared.rootViewController else {
                                        return
                                    }
                                    
                                    Notificare.shared.scannables().startQrCodeScannableSession(controller: rootViewController, modal: true)
                                }
                                .padding(.top, 12)
                            }
                        } else {
                            Button(String(localized: "home_scan_nfc_button")) {
                                guard let rootViewController = UIApplication.shared.rootViewController else {
                                    return
                                }
                                
                                Notificare.shared.scannables().startQrCodeScannableSession(controller: rootViewController, modal: true)
                            }
                            .buttonStyle(PrimaryButton())
                        }
                    }
                }
                
                Group {
                    if viewModel.hasLocationPermissions {
                        GroupBox {
                            VStack(alignment: .leading, spacing: 8) {
                                if #available(iOS 15.0, *) {
                                    Label(String(localized: "home_nearby_title"), systemImage: "sensor.tag.radiowaves.forward")
                                        .font(.headline)
                                } else {
                                    HStack(spacing: 10) {
                                        Image("sensor.tag.radiowaves.forward")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24, height: 18)
                                        
                                        Text(String(localized: "home_nearby_title"))
                                            .font(.headline)
                                    }
                                }
                                
                                if viewModel.rangedBeacons.isEmpty {
                                    Text(String(localized: "home_nearby_no_beacons"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    VStack {
                                        ForEach(Array(viewModel.rangedBeacons.enumerated()), id: \.1) { index, beacon in
                                            BeaconRow(beacon: beacon)
                                            
                                            if index < viewModel.rangedBeacons.count - 1 {
                                                Divider()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        AlertBlock(title: String(localized: "home_nearby_alert_permissions_title"), systemImage: "exclamationmark.triangle") {
                            Text(String(localized: "home_nearby_alert_permissions_message"))
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Button {
                                viewModel.enableLocationUpdates()
                            } label: {
                                Text(String(localized: "home_nearby_alert_permissions_button"))
                            }
                        }
                    }
                }
                
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(String(localized: "home_events_title"), systemImage: "calendar.badge.plus")
                            .font(.headline)
                        
                        Text(String(localized: "home_events_message"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 8)
                        
                        NavigationLink {
                            EventsView()
                        } label: {
                            Text(String(localized: "home_events_button"))
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(String(localized: "home_title"))
        .sheet(isPresented: $viewModel.showingSettingsPermissionDialog) {
            VStack(spacing: 0) {
                WebView(url: PRIVACY_DETAILS_URL)
                
                Button(String(localized: "shared_continue_to_settings")) {
                    guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else {
                        viewModel.showingSettingsPermissionDialog = false
                        return
                    }
                    
                    UIApplication.shared.open(url)
                    viewModel.showingSettingsPermissionDialog = false
                }
                .buttonStyle(PrimaryButton())
                .padding()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
        
        HomeView().preferredColorScheme(.dark)
    }
}
