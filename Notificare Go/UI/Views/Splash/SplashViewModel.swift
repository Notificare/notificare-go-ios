//
//  SplashViewModel.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 10/03/2022.
//

import Combine
import AuthenticationServices
import Foundation
import NotificareKit

@MainActor
class SplashViewModel: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Notificare.shared.launch()
        
        NotificationCenter.default.publisher(for: .notificareLaunched, object: nil)
            .sink { _ in
                guard let user = Keychain.standard.user else {
                    ContentRouter.main.route = .intro
                    return
                }
                
                let provider = ASAuthorizationAppleIDProvider()
                provider.getCredentialState(forUserID: user.id) { state, error in
                    let route: ContentRouter.Route
                    
                    switch state {
                    case .authorized:
                        route = .main
                    case .notFound, .revoked, .transferred:
                        // Remove the user identifier from the keychain and run the intro again.
                        Keychain.standard.user = nil
                        route = .intro
                    default:
                        fatalError("Unhandled credential state.")
                    }
                    
                    DispatchQueue.main.async {
                        ContentRouter.main.route = route
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}
