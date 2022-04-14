//
//  SettingsView.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 18/02/2022.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    private let user = Keychain.standard.user!
    
    init() {
        self._viewModel = StateObject(wrappedValue: SettingsViewModel())
    }
    
    var body: some View {
        List {
            Section {
                NavigationLink {
                    UserProfileView()
                } label: {
                    HStack(alignment: .center, spacing: 16) {
                        AsyncImageCompat(url: user.gravatarUrl) { image in
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
            
            Section {
                NavigationLink {
                    InboxView()
                } label: {
                    Label {
                        Text(verbatim: String(localized: "settings_inbox_title"))
                        
                        Spacer(minLength: 16)
                        
                        if viewModel.badge > 0 {
                            BadgeView(badge: viewModel.badge)
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
        }
        .navigationTitle(String(localized: "settings_title"))
        .alert(isPresented: $viewModel.showingSettingsPermissionDialog) {
            Alert(
                title: Text(String(localized: "intro_location_alert_denied_title")),
                message: Text(String(localized: "intro_location_alert_denied_message")),
                primaryButton: .cancel(Text(String(localized: "shared_dialog_button_skip")), action: {
                    withAnimation {
                        viewModel.locationEnabled = false
                    }
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
