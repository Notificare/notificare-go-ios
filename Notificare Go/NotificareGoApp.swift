//
//  Notificare_GoApp.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 18/02/2022.
//

import SwiftUI
import NotificareKit

@main
struct NotificareGoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var alertController = AlertController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(alertController)
                .alert(item: $alertController.info, content: { $0.alert })
                .onOpenURL { url in
                    print("Received a deep link: \(url.absoluteString)")
                    
                    if handleUniversalLink(url) {
                        print("Universal link processed by the app.")
                        return
                    }
                    
                    if handleDeepLink(url) {
                        print("Deep link processed by the app.")
                        return
                    }
                    
                    if Notificare.shared.handleDynamicLinkUrl(url) {
                        print("Universal link processed by Notificare.")
                        return
                    }
                }
        }
    }
    
    private func handleDeepLink(_ url: URL) -> Bool {
        guard url.scheme == Bundle.main.bundleIdentifier else {
            print("Scheme mismatch.")
            return false
        }
        
        guard url.host == "go.notifica.re" else {
            print("Host mismatch.")
            return false
        }
        
        guard let action = url.pathComponents.first else {
            print("No path components available.")
            return false
        }
        
        // TODO: add some deep links
        
        return true
    }
    
    private func handleUniversalLink(_ url: URL) -> Bool {
        guard let code = extractCodeParameter(from: url) else {
            print("Invalid URL: \(url.absoluteString)")
            return false
        }
        
        guard Preferences.standard.appConfiguration == nil else {
            print("Application already configured.")
            alertController.info = AlertController.AlertInfo(
                Alert(
                    title: Text(String(localized: "content_configured_dialog_title")),
                    message: Text(String(localized: "content_configured_dialog_message")),
                    dismissButton: .default(Text(String(localized: "shared_dialog_button_ok")))
                )
            )
            
            return true
        }
        
        Task {
            do {
                let response = try await APIClient.getConfiguration(code: code)
                
                // Persist the configuration.
                Preferences.standard.appConfiguration = AppConfiguration(
                    applicationKey: response.demo.applicationKey,
                    applicationSecret: response.demo.applicationSecret
                )
                
                ContentRouter.main.route = .splash
            } catch {
                alertController.info = AlertController.AlertInfo(
                    Alert(
                        title: Text(String(localized: "content_configuration_error_dialog_title")),
                        message: Text(String(localized: "content_configuration_error_dialog_message")),
                        dismissButton: .default(Text(String(localized: "shared_dialog_button_ok")))
                    )
                )
            }
        }
        
        return true
    }
}
