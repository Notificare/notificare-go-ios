//
//  SplashView.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 10/03/2022.
//

import Combine
import SwiftUI
import NotificareKit
import NotificareInAppMessagingKit

struct SplashView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: ContentRouter
    @State private(set) var isShowingContent = false
    @State private(set) var isShowingProgress = false
    @State private var contentHeight = 0.0
    
    private var readinessStatePublisher: Publishers.Zip<NotificationCenter.Publisher, AppState.AuthenticationStatePublisher> {
        Publishers.Zip(
            NotificationCenter.default.publisher(for: .notificareLaunched, object: nil),
            appState.$authenticationStateAvailable.eraseToAnyPublisher()
        )
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            if isShowingContent {
                Image("artwork_logo_lettering")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 192)
                    .overlay(DetermineSize())
                    .onPreferenceChange(SizePreferenceKey.self) { size in
                        contentHeight = size.height
                    }
            
                if isShowingProgress {
                    ProgressView()
                        .offset(y: contentHeight + 32)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            guard let appConfiguration = Preferences.standard.appConfiguration else {
                withAnimation {
                    router.route = .scanner
                }
                
                return
            }
            
            // Prevent the logo from being shown when it will get immediately
            // replaced with the scanner.
            isShowingContent = true
            
            if !Notificare.shared.isConfigured {
                // Show the spinner only when returning from the scanner.
                // Notificare will be configured during app launch otherwise.
                isShowingProgress = true
                
                Notificare.shared.configure(
                    servicesInfo: NotificareServicesInfo(
                        applicationKey: appConfiguration.applicationKey,
                        applicationSecret: appConfiguration.applicationSecret
                    )
                )
            }

            Notificare.shared.launch() { _ in }
        }
        .onReceive(readinessStatePublisher) { (_, authStateAvailable) in
            guard authStateAvailable else { return }
            
            guard Preferences.standard.introFinished, appState.currentUser != nil else {
                Notificare.shared.inAppMessaging().hasMessagesSuppressed = true

                withAnimation {
                    router.route = .intro
                }
                
                return
            }
            
            Task {
                await loadRemoteConfig()
                
                withAnimation {
                    router.route = .main
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
