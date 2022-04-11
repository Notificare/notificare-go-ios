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
    @Published private(set) var isShowingProgress = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        guard let appConfiguration = Preferences.standard.appConfiguration else {
            DispatchQueue.main.async {
                ContentRouter.main.route = .scanner
            }
            
            return
        }
        
        isShowingProgress = true
        
        Notificare.shared.configure(
            servicesInfo: NotificareServicesInfo(
                applicationKey: appConfiguration.applicationKey,
                applicationSecret: appConfiguration.applicationSecret
            )
        )

        Notificare.shared.launch()
        
        NotificationCenter.default.publisher(for: .notificareLaunched, object: nil)
            .sink { _ in
                guard Preferences.standard.introFinished, let user = Keychain.standard.user else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        ContentRouter.main.route = .intro
                    }
                    
                    return
                }
                
                Task {
                    await self.checkRemoteConfig()
                    
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
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            ContentRouter.main.route = route
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func checkRemoteConfig() async {
        do {
            let assets = try await Notificare.shared.assets().fetch(group: "config")
            
            if let config = assets.first, let storeEnabled = config.extra["storeEnabled"] as? Bool, storeEnabled {
                Preferences.standard.storeEnabled = true
                return
            }
        } catch {
            if case let NotificareNetworkError.validationError(response, _, _) = error, response.statusCode == 404 {
                // The config asset group is not available. The store can be enabled.
                Preferences.standard.storeEnabled = true
                return
            }
            
            print("Failed to fetch the remote config. \(error)")
        }
        
        Preferences.standard.storeEnabled = false
    }
}
