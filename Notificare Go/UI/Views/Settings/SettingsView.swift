//
//  SettingsView.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 18/02/2022.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink {
                        UserProfileView()
                    } label: {
                        HStack(alignment: .center, spacing: 16) {                            
                            AsyncImageCompat(url: URL(string: "https://gravatar.com/avatar/1a73f51bd2d8f8114835508ecd678c66?s=400&d=blank")) { image in
                                Image(uiImage: image)
                                    .resizable()
                            } placeholder: {
                                Color.clear
                            }
                            .frame(width: 64, height: 64)
                            .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(verbatim: "Helder Pinhal")
                                    .font(.title2)
                                    .lineLimit(1)
                                
                                Text(verbatim: "Regular user")
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
                                .background(Color.red)
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
                                .background(Color.green)
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
                                    .background(Color.blue)
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
            }
            .navigationTitle(String(localized: "settings_title"))
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
