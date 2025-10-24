//
//  SettingsView.swift
//  Actito Go
//
//  Created by Helder Pinhal on 18/02/2022.
//

import SwiftUI
import OSLog
import ActitoKit

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel: SettingsViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: SettingsViewModel())
    }
    
    var body: some View {
        List {
            if let user = appState.currentUser {
                Section {
                    NavigationLink(isActive: $appState.showUserProfile) {
                        UserProfileView()
                    } label: {
                        HStack(alignment: .center, spacing: 16) {
                            AsyncImageCompat(url: user.pictureUrl) { image in
                                Image(uiImage: image)
                                    .resizable()
                            } placeholder: {
                                Color.clear
                            }
                            .frame(width: 64, height: 64)
                            .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(verbatim: user.name ?? String(localized: "shared_anonymous_user"))
                                    .font(.title2)
                                    .lineLimit(1)
                                
                                Text(verbatim: user.id)
                                    .font(.subheadline)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            
            Section {
                NavigationLink(isActive: $appState.showInbox) {
                    InboxView()
                } label: {
                    Label {
                        HStack {
                            Text(verbatim: String(localized: "settings_inbox_title"))

                            Spacer(minLength: 16)

                            if viewModel.badge > 0 {
                                BadgeView(badge: viewModel.badge)
                            }
                        }
                    } icon: {
                        Image(systemName: "tray.and.arrow.down.fill")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .padding(6)
                            .background(Color("color_settings_location"))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
            }
            
            Section {
                Toggle(isOn: $viewModel.notificationsEnabled) {
                    Label {
                        Text(verbatim: String(localized: "settings_notifications_title"))
                    } icon: {
                        Image(systemName: "bell.badge.fill")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .padding(6)
                            .background(Color("color_settings_notifications"))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
            } header: {
                //
            } footer: {
                Text(verbatim: String(localized: "settings_notifications_helper_text"))
            }
            
            if viewModel.notificationsEnabled {
                Section {
                    Toggle(isOn: $viewModel.doNotDisturbEnabled) {
                        Label {
                            Text(verbatim: String(localized: "settings_dnd_title"))
                        } icon: {
                            Image(systemName: "moon.fill")
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .padding(6)
                                .background(Color("color_settings_dnd"))
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                    
                    if viewModel.doNotDisturbEnabled {
                        DatePicker(
                            String(localized: "settings_dnd_start"),
                            selection: $viewModel.doNotDisturbStart,
                            displayedComponents: .hourAndMinute
                        )
                        
                        DatePicker(
                            String(localized: "settings_dnd_end"),
                            selection: $viewModel.doNotDisturbEnd,
                            displayedComponents: .hourAndMinute
                        )
                    }
                } header: {
                    //
                } footer: {
                    Text(verbatim: String(localized: "settings_dnd_helper_text"))
                }
            }
            
            Section {
                Toggle(isOn: $viewModel.locationEnabled) {
                    Label {
                        Text(verbatim: String(localized: "settings_location_title"))
                    } icon: {
                        Image(systemName: "location.fill")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .padding(6)
                            .background(Color("color_settings_location"))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
            } header: {
                //
            } footer: {
                Text(verbatim: String(localized: "settings_location_helper_text"))
            }
            
            Section {
                Toggle(isOn: $viewModel.announcementsTagEnabled) {
                    Text(String(localized: "settings_tags_announcements_title"))
                }

                Toggle(isOn: $viewModel.marketingTagEnabled) {
                    Text(String(localized: "settings_tags_marketing_title"))
                }

                Toggle(isOn: $viewModel.bestPracticesTagEnabled) {
                    Text(String(localized: "settings_tags_best_practices_title"))
                }
                
                Toggle(isOn: $viewModel.productUpdatesTagEnabled) {
                    Text(String(localized: "settings_tags_product_updates_title"))
                }
                
                Toggle(isOn: $viewModel.engineeringTagEnabled) {
                    Text(String(localized: "settings_tags_engineering_title"))
                }
                
                Toggle(isOn: $viewModel.staffTagEnabled) {
                    Text(String(localized: "settings_tags_staff_title"))
                }
            } header: {
                Text("Subscribe to topics")
            }
            
            if let application = Actito.shared.application {
                Section {
                    VStack {
                        Text(verbatim: application.name)
                            .font(.headline)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            .multilineTextAlignment(.center)
                        
                        if #available(iOS 15.0, *) {
                            Text(verbatim: application.id)
                                .font(.caption)
                                .foregroundColor(Color(UIColor.secondaryLabel))
                                .multilineTextAlignment(.center)
                                .textSelection(.enabled)
                        } else {
                            Text(verbatim: application.id)
                                .font(.caption)
                                .foregroundColor(Color(UIColor.secondaryLabel))
                                .multilineTextAlignment(.center)
                        }
                        
                        Text(verbatim: "v\(Bundle.main.applicationVersion)")
                            .font(.caption)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .listRowBackground(Color.clear)
            }
        }
        .customListStyle()
        .navigationTitle(String(localized: "settings_title"))
        .sheet(isPresented: $viewModel.showingSettingsPermissionDialog) {
            VStack(spacing: 0) {
                WebView(url: PRIVACY_DETAILS_URL)

                Button {
                    guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else {
                        viewModel.showingSettingsPermissionDialog = false
                        return
                    }

                    UIApplication.shared.open(url)
                    viewModel.showingSettingsPermissionDialog = false
                } label: {
                    Text(String(localized: "shared_continue_to_settings"))
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
                .adaptivePrimaryButton()
                .padding()
            }
        }
        .onAppear {
            Task {
                do {
                    try await Actito.shared.events().logPageView(.settings)
                } catch {
                    Logger.main.error("Failed to log a custom event. \(error.localizedDescription)")
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
