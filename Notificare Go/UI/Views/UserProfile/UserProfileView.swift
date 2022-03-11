//
//  UserProfileView.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 22/02/2022.
//

import SwiftUI
import NotificareKit

struct UserProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    
    private let user = Keychain.standard.user!
    
    var body: some View {
        List {
            VStack(alignment: .center, spacing: 0) {
                AsyncImageCompat(url: user.gravatarUrl) { image in
                    Image(uiImage: image)
                        .resizable()
                } placeholder: {
                    Color.clear
                }
                .frame(width: 128, height: 128)
                .clipShape(Circle())
                
                Text(verbatim: user.name ?? String(localized: "shared_anonymous_user"))
                    .font(.title2)
                    .lineLimit(1)
                    .padding(.top)
                
                Text(verbatim: user.id)
                    .font(.subheadline)
                    .lineLimit(1)
                    .contextMenu {
                        Button {
                            UIPasteboard.general.string = user.id
                        } label: {
                            Label(String(localized: "user_profile_copy_id"), systemImage: "doc.on.doc")
                        }
                    }
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
            
            Section {
                NavigationLink {
                    EmptyView()
                } label: {
                    Text(verbatim: String(localized: "user_profile_membership_card"))
                }
            }
            
            if !viewModel.profileInformation.isEmpty {
                Section {
                    ForEach($viewModel.profileInformation) { $item in
                        if item.type == "text" || item.type == "number" {
                            TextField(
                                item.label,
                                text: $item.value
                            )
                        } else if item.type == "boolean" {
                            Toggle(
                                "Loves Notificare",
                                isOn: Binding(
                                    get: { (item.value as NSString).boolValue },
                                    set: { item.value = $0.description }
                                )
                            )
                        } else if item.type == "date" {
                            DatePicker(
                                item.label,
                                selection: Binding(
                                    get: { ISO8601DateFormatter().date(from: item.value) ?? Date() },
                                    set: { item.value = ISO8601DateFormatter().string(from: $0) }
                                ),
                                displayedComponents: .date
                            )
                        } else {
                            HStack {
                                Text(verbatim: item.label)
                                Spacer()
                                Text(verbatim: String(localized: "user_profile_unsupported_user_data_type"))
                                    .foregroundColor(Color(.tertiaryLabel))
                            }
                        }
                    }
                } header: {
                    Text(verbatim: String(localized: "user_profile_personal_information"))
                }
            }
            
//            Section {
//                Button {
//
//                } label: {
//                    Text(verbatim: String(localized: "user_profile_sign_out"))
//                        .foregroundColor(.red)
//                }
//            }
        }
        .navigationTitle(String(localized: "user_profile_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserProfileView()
        }
    }
}
