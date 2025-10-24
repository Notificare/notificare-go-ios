//
//  SplashView.swift
//  Actito Go
//
//  Created by Helder Pinhal on 10/03/2022.
//

import Combine
import SwiftUI
import OSLog
import ActitoKit
import ActitoInAppMessagingKit

struct SplashView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: ContentRouter
    @State private(set) var isShowingContent = false
    @State private(set) var isShowingProgress = false
    @State private var contentHeight = 0.0
    
    private var readinessStatePublisher: Publishers.Zip<NotificationCenter.Publisher, AppState.AuthenticationStatePublisher> {
        Publishers.Zip(
            NotificationCenter.default.publisher(for: .actitoLaunched, object: nil),
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
            
            if !Actito.shared.isConfigured {
                // Show the spinner only when returning from the scanner.
                // Actito will be configured during app launch otherwise.
                isShowingProgress = true
                
                Actito.shared.configure(
                    servicesInfo: ActitoServicesInfo(
                        applicationKey: appConfiguration.applicationKey,
                        applicationSecret: appConfiguration.applicationSecret
                    )
                )
            }

            Task {
                do {
                    try await Actito.shared.launch()
                } catch {
                    Logger.main.error("Failed to launch Actito. \(error)")
                }
            }
        }
        .onReceive(readinessStatePublisher) { (_, authStateAvailable) in
            guard authStateAvailable else { return }

            guard Preferences.standard.introFinished, let currentUser = appState.currentUser else {
                Actito.shared.inAppMessaging().hasMessagesSuppressed = true

                withAnimation {
                    router.route = .intro
                }
                
                return
            }

            Task {
                await loadRemoteConfig()

                do {
                    try await Actito.shared.device().updateUser(userId: currentUser.id, userName: currentUser.name)
                } catch {
                    Logger.main.error("Failed to update user. \(error.localizedDescription)")
                }

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
