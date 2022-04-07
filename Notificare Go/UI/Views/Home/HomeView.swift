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
    
    init() {
        self._viewModel = StateObject(wrappedValue: HomeViewModel())
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                TopProductsView(products: viewModel.highlightedProducts)
                    .padding()
                
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(String(localized: "home_scan_title"), systemImage: "barcode.viewfinder")
                            .font(.headline)
                        
                        Text(String(localized: "home_scan_message"))
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Button(String(localized: "home_scan_button")) {
                            if Notificare.shared.scannables().canStartNfcScannableSession {
                                Notificare.shared.scannables().startNfcScannableSession()
                            } else {
                                guard let rootViewController = UIApplication.shared.rootViewController else {
                                    return
                                }
                                
                                Notificare.shared.scannables().startQrCodeScannableSession(controller: rootViewController, modal: true)
                            }
                        }
                        .buttonStyle(PrimaryButton())
                        .padding(.top, 8)
                    }
                }
                .padding()
                
                VStack(alignment: .leading) {
                    Text(String(localized: "home_nearby_title"))
                        .font(.title2)
                        .bold()
                    
                    if viewModel.hasLocationPermissions {
                        GroupBox {
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
                .padding()
            }
        }
        .navigationTitle(String(localized: "home_title"))
        .alert(isPresented: $viewModel.showingSettingsPermissionDialog) {
            Alert(
                title: Text(String(localized: "intro_location_alert_denied_title")),
                message: Text(String(localized: "intro_location_alert_denied_message")),
                primaryButton: .cancel(Text(String(localized: "shared_dialog_button_skip")), action: {
                    
                }),
                secondaryButton: .default(Text(String(localized: "shared_dialog_button_ok")), action: {
                    guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else {
                        return
                    }
                    
                    UIApplication.shared.open(url)
                })
            )
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
        
        HomeView().preferredColorScheme(.dark)
    }
}
