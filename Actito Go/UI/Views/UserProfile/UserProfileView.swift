//
//  UserProfileView.swift
//  Actito Go
//
//  Created by Helder Pinhal on 22/02/2022.
//

import SwiftUI
import ActitoKit
import PassKit
import FirebaseAuth
import OSLog

struct UserProfileView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: UserProfileViewModel
    @State private var showDeleteAccountConfirmation = false

    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]

        return formatter
    }()

    init() {
        self._viewModel = StateObject(wrappedValue: UserProfileViewModel())
    }

    var body: some View {
        List {
            if let user = appState.currentUser {
                VStack(alignment: .center, spacing: 0) {
                    AsyncImageCompat(url: user.pictureUrl) { image in
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
            }

            if let membershipCardUrl = viewModel.membershipCardUrl {
                Section {
                    Button(String(localized: "user_profile_membership_card")) {
                        guard let url = URL(string: membershipCardUrl) else { return }
                        guard let rootViewController = UIApplication.shared.rootViewController else { return }

                        do {
                            let data = try Data(contentsOf: url)
                            let pass = try PKPass(data: data)

                            guard let controller = PKAddPassesViewController(pass: pass) else { return }
                            rootViewController.present(controller, animated: true)
                        } catch {
                            Logger.main.error("Failed to fetch the PKPass.")
                        }
                    }
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
                                item.label,
                                isOn: Binding(
                                    get: { (item.value as NSString).boolValue },
                                    set: { item.value = $0.description }
                                )
                            )
                        } else if item.type == "date" {
                            DatePicker(
                                item.label,
                                selection: Binding(
                                    get: { dateFormatter.date(from: item.value) ?? Date() },
                                    set: { item.value = dateFormatter.string(from: $0) }
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

            Section {
                Button {
                    showDeleteAccountConfirmation = true
                } label: {
                    Text(verbatim: String(localized: "user_profile_delete_account_button"))
                        .foregroundColor(.red)
                }
                .alert(isPresented: $showDeleteAccountConfirmation) {
                    Alert(
                        title: Text("user_profile_delete_account_confirmation_title"),
                        message: Text("user_profile_delete_account_confirmation_message"),
                        primaryButton: .destructive(Text("shared_dialog_button_yes"), action: onDeleteAccountClicked),
                        secondaryButton: .cancel(Text("shared_dialog_button_cancel"))
                    )
                }
            }
        }
        .customListStyle()
        .navigationTitle(String(localized: "user_profile_title"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                do {
                    try await Actito.shared.events().logPageView(.userProfile)
                } catch {
                    Logger.main.error("Failed to log a custom event. \(error.localizedDescription)")
                }
            }
        }
    }

    private func onDeleteAccountClicked() {
        Task {
            do {
                try await viewModel.deleteAccount()

                withAnimation {
                    ContentRouter.main.route = .intro
                }
            } catch {
                guard let authErrorCode = AuthErrorCode(rawValue: (error as NSError).code),
                      authErrorCode == AuthErrorCode.requiresRecentLogin
                else {
                    Logger.main.error("Failed to delete account. \(error.localizedDescription)")

                    return
                }

                do {
                    try await viewModel.reauthenticate()
                    try await viewModel.deleteAccount()

                    withAnimation {
                        ContentRouter.main.route = .intro
                    }
                } catch {
                    Logger.main.error("Reauthenticate and delete account failed. \(error.localizedDescription)")
                }
            }
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserProfileView()
        }
    }
}
