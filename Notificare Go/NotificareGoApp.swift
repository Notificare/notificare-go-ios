//
//  Notificare_GoApp.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 18/02/2022.
//

import SwiftUI
import NotificareKit

internal let PRIVACY_DETAILS_URL = URL(string: "https://ntc.re/0OMbJKeJ2m")!

@main
struct NotificareGoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var alertController = AlertController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(alertController)
                .alert(item: $alertController.info, content: { $0.alert })
                .onOpenURL { handleConfigurationUniversalLink($0) }
        }
    }
    
    private func handleConfigurationUniversalLink(_ url: URL) {
        guard let code = extractCodeParameter(from: url) else { return }
        
        guard Preferences.standard.appConfiguration == nil else {
            print("Application already configured.")
            alertController.info = AlertController.AlertInfo(
                Alert(
                    title: Text(String(localized: "content_configured_dialog_title")),
                    message: Text(String(localized: "content_configured_dialog_message")),
                    dismissButton: .default(Text(String(localized: "shared_dialog_button_ok")))
                )
            )
            
            return
        }
        
        Task {
            do {
                let response = try await APIClient.getConfiguration(code: code)
                
                // Persist the configuration.
                Preferences.standard.appConfiguration = AppConfiguration(
                    applicationKey: response.demo.applicationKey,
                    applicationSecret: response.demo.applicationSecret,
                    loyaltyProgramId: response.demo.loyaltyProgram
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
    }
}
