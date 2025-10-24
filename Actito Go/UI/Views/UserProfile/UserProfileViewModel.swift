//
//  UserProfileViewModel.swift
//  Actito Go
//
//  Created by Helder Pinhal on 11/03/2022.
//

import Combine
import Foundation
import FirebaseAuth
import ActitoKit
import AuthenticationServices
import OSLog

@MainActor
class UserProfileViewModel: ObservableObject {
    @Published private(set) var membershipCardUrl: String?
    @Published var profileInformation: [ProfileInformationItem] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var appleSignInDelegate: AppleSignInDelegate?
    
    init() {
        self.membershipCardUrl = Preferences.standard.membershipCardUrl
        
        Task {
            do {
                let fields = try await Actito.shared.fetchApplication().userDataFields
                let userData = try await Actito.shared.device().fetchUserData()

                self.profileInformation = fields.map { field in
                    ProfileInformationItem(
                        key: field.key,
                        label: field.label,
                        type: field.type,
                        value: userData[field.key] ?? ""
                    )
                }
                
                startListeningToChanges()
            } catch {
                //
            }
        }
    }
    
    func deleteAccount() async throws {
        // Remove the Firebase user.
        try await Auth.auth().currentUser!.delete()
        
        // Register the device as anonymous.
        try await Actito.shared.device().updateUser(userId: nil, userName: nil)
    }
    
    func reauthenticate() async throws {
        let nonce = randomNonceString()
        self.appleSignInDelegate = AppleSignInDelegate(nonce: nonce)
        
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.email, .fullName]
        request.nonce = sha256(nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = appleSignInDelegate
        controller.presentationContextProvider = UIApplication.shared.rootViewController as? ASAuthorizationControllerPresentationContextProviding
        
        return try await withCheckedThrowingContinuation { continuation in
            self.appleSignInDelegate?.continuation = continuation
            controller.performRequests()
        }
    }
    
    private func startListeningToChanges() {
        $profileInformation
            .debounce(for: .seconds(1.5), scheduler: RunLoop.main)
            .sink { profile in
                var userData: [String : String] = [:]
                profile.forEach { userData[$0.key] = $0.value }
                
                Actito.shared.device().updateUserData(userData) { result in
                    switch result {
                    case .success:
                        Logger.main.info("Updated user data.")
                    case .failure:
                        Logger.main.error("Failed to update user data.")
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    
    struct ProfileInformationItem: Identifiable {
        let id = UUID()
        let key: String
        let label: String
        let type: String
        var value: String
    }
}

extension UserProfileViewModel {
    class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate {
        private let nonce: String
        var continuation: CheckedContinuation<Void, Error>?
        
        init(nonce: String) {
            self.nonce = nonce
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            guard let continuation = continuation else { return }

            guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let idToken = appleCredential.identityToken,
                  let idTokenStr = String(data: idToken, encoding: .utf8)
            else {
                Logger.main.error("Unable to acquire the ID token string.")
                continuation.resume(throwing: AuthenticationError.missingCredentials)
                return
            }
            
            let credential = OAuthProvider.credential(
                providerID: AuthProviderID.apple,
                idToken: idTokenStr,
                rawNonce: self.nonce
            )
            
            Task {
                do {
                    try await Auth.auth().currentUser!.reauthenticate(with: credential)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            continuation?.resume(throwing: error)
        }
    }
}

extension UserProfileViewModel {
    enum AuthenticationError: Error {
        case missingCredentials
    }
}
