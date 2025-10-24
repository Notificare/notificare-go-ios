//
//  IntroView.swift
//  Actito Go
//
//  Created by Helder Pinhal on 22/02/2022.
//

import AuthenticationServices
import CoreLocation
import SwiftUI
import FirebaseAuth
import SwiftUIIntrospect
import ActitoKit
import ActitoInAppMessagingKit
import OSLog

struct IntroView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel: IntroViewModel
    @State private var nonce = ""
    @EnvironmentObject private var alertController: AlertController
    @EnvironmentObject private var router: ContentRouter
    
    init() {
        self._viewModel = StateObject(wrappedValue: IntroViewModel())
        
        UIPageControl.appearance().currentPageIndicatorTintColor = .init(named: "color_intro_indicator_current")
        UIPageControl.appearance().pageIndicatorTintColor = .init(named: "color_intro_indicator_unselected")
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                TabView(selection: $viewModel.currentTab) {
                    IntroSlideView(slide: .intro) {
                        Button() {
                            withAnimation {
                                viewModel.currentTab += 1
                            }
                        } label: {
                            Text(String(localized: "intro_welcome_button"))
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                        }
                        .adaptivePrimaryButton()
                    }
                    .tag(0)
                    
                    IntroSlideView(slide: .notifications) {
                        Button() {
                            viewModel.enableRemoteNotifications()
                        } label: {
                            Text(String(localized: "intro_notifications_button"))
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                        }
                        .adaptivePrimaryButton()
                    }
                    .tag(1)
                    
                    IntroSlideView(slide: .location) {
                        Button() {
                            viewModel.enableLocationUpdates()
                        } label: {
                            Text(String(localized: "intro_location_button"))
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                        }
                        .adaptivePrimaryButton()
                    }
                    .tag(2)
                    
                    IntroSlideView(slide: .login) {
                        SignInWithAppleButton(
                            .signIn,
                            onRequest: { request in
                                self.nonce = randomNonceString()
                                request.nonce = sha256(self.nonce)
                                request.requestedScopes = [.email, .fullName]
                            },
                            onCompletion: handleAuthenticationCallback
                        )
                        .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
                        .frame(height: 50)
                    }
                    .tag(3)
                }
                .tabViewStyle(.page)
                .introspect(.scrollView, on: .iOS(.v14, .v15, .v16, .v17)) { scrollView in
                    scrollView.bounces = false
                    scrollView.isScrollEnabled = false
                }
            }
            .navigationTitle(String(localized: "intro_title"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: viewModel.showingSettingsPermissionDialog) { newValue in
            guard newValue else { return }
            
            alertController.info = AlertController.AlertInfo(
                Alert(
                    title: Text(String(localized: "intro_location_alert_denied_title")),
                    message: Text(String(localized: "intro_location_alert_denied_message")),
                    primaryButton: .cancel(Text(String(localized: "shared_dialog_button_skip")), action: {
                        withAnimation {
                            viewModel.currentTab += 1
                        }
                    }),
                    secondaryButton: .default(Text(String(localized: "shared_dialog_button_ok")), action: {
                        guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else {
                            return
                        }
                        
                        UIApplication.shared.open(url)
                    })
                )
            )
        }
        .onChange(of: alertController.info) { _ in
            // Reset the flag upon changing the presented alert.
            // Otherwise it will remain set as true.
            viewModel.showingSettingsPermissionDialog = false
        }
    }
    
    private func handleAuthenticationCallback(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard let appleCredential = auth.credential as? ASAuthorizationAppleIDCredential,
                  let idToken = appleCredential.identityToken,
                  let idTokenStr = String(data: idToken, encoding: .utf8)
            else {
                Logger.main.error("Unable to acquire the ID token string.")
                return
            }
            
            let credential = OAuthProvider.credential(
                providerID: AuthProviderID.apple,
                idToken: idTokenStr,
                rawNonce: self.nonce
            )
            
            Task {
                do {
                    let result = try await Auth.auth().signIn(with: credential)
                    
                    if let name = appleCredential.name {
                        let profileChangeRequest = result.user.createProfileChangeRequest()
                        profileChangeRequest.displayName = name
                        
                        try await profileChangeRequest.commitChanges()
                    }
                } catch {
                    Logger.main.error("Failed to login with Firebase. \(error.localizedDescription)")
                    return
                }
                
                await loadRemoteConfig()
                
                do {
                    let user = Auth.auth().currentUser!
                    try await Actito.shared.device().updateUser(userId: user.uid, userName: user.displayName)

                    if let programId = Preferences.standard.appConfiguration?.loyaltyProgramId {
                        Logger.main.info("Creating loyalty program enrollment.")
                        let response = try await APIClient.createEnrollment(
                            programId: programId,
                            payload: APIClient.CreateEnrollmentPayload(
                                userId: user.uid,
                                memberId: user.uid,
                                fields: [
                                    APIClient.CreateEnrollmentPayload.Field(
                                        key: "name",
                                        value: user.displayName ?? String(localized: "shared_anonymous_user")
                                    ),
                                    APIClient.CreateEnrollmentPayload.Field(
                                        key: "email",
                                        value: user.email ?? ""
                                    ),
                                ]
                            )
                        )

                        Preferences.standard.membershipCardUrl = response.saveLinks.appleWallet
                    }
                } catch {
                    // TODO: handle error scenario.
                }
                
                do {
                    try await Actito.shared.events().logIntroFinished()
                } catch {
                    Logger.main.error("Failed to log a custom event. \(error.localizedDescription)")
                }
                
                Preferences.standard.introFinished = true
                Actito.shared.inAppMessaging().hasMessagesSuppressed = false

                withAnimation {
                    router.route = .main
                }
            }
        case .failure(let error):
            Logger.main.error("Authorization failed. \(error.localizedDescription)")
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
        
        IntroView()
            .preferredColorScheme(.dark)
    }
}

private struct IntroSlideView<Footer: View>: View {
    private let slide: Slide
    private let footer: () -> Footer
    
    init(slide: Slide, @ViewBuilder footer: @escaping () -> Footer) {
        self.slide = slide
        self.footer = footer
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Image(slide.artwork)
                .resizable()
                .scaledToFit()
                .frame(height: 192)
                .padding()
            
            Text(slide.title)
                .font(.title)
                .lineLimit(1)
                .padding(.horizontal)
                .padding(.top, 32)
            
            Text(slide.message)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top, 8)
            
            Spacer()
            
            footer()
                .padding(32)
                .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    enum Slide {
        case intro
        case notifications
        case location
        case login
        
        var artwork: String {
            switch self {
            case .intro:
                return "artwork_intro"
            case .notifications:
                return "artwork_remote_notifications"
            case .location:
                return "artwork_location"
            case .login:
                return "artwork_login"
            }
        }
        
        var title: String {
            switch self {
            case .intro:
                return String(localized: "intro_welcome_title")
            case .notifications:
                return String(localized: "intro_notifications_title")
            case .location:
                return String(localized: "intro_location_title")
            case .login:
                return String(localized: "intro_login_title")
            }
        }
        
        var message: String {
            switch self {
            case .intro:
                return String(localized: "intro_welcome_message")
            case .notifications:
                return String(localized: "intro_notifications_message")
            case .location:
                return String(localized: "intro_location_message")
            case .login:
                return String(localized: "intro_login_message")
            }
        }
    }
}

extension IntroSlideView where Footer == EmptyView {
    init(slide: Slide) {
        self.init(slide: slide, footer: { EmptyView() })
    }
}

private extension ASAuthorizationAppleIDCredential {
    var name: String? {
        guard let nameComponents = fullName else {
            return nil
        }
        var parts = [String]()
        
        if let givenName = nameComponents.givenName {
            parts.append(givenName)
        }
        
        if let familyName = nameComponents.familyName {
            parts.append(familyName)
        }
        
        guard !parts.isEmpty else {
            return nil
        }
        
        return parts.joined(separator: " ")
    }
}
