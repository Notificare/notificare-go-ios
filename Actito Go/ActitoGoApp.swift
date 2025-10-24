//
//  Actito_GoApp.swift
//  Actito Go
//
//  Created by Helder Pinhal on 18/02/2022.
//

import SwiftUI
import ActitoKit
import OSLog

internal let PRIVACY_DETAILS_URL = URL(string: "https://ntc.re/0OMbJKeJ2m")!

@main
struct ActitoGoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var appState = AppState()
    @StateObject private var alertController = AlertController()
    
    private let shortcutsService = ShortcutsService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(alertController)
                .environmentObject(shortcutsService)
                .alert(item: $alertController.info, content: { $0.alert })
                .onOpenURL {
                    handleConfigurationUniversalLink($0)
                    handleDeepLink($0)
                }
                .onChange(of: scenePhase) { scenePhase in
                    switch scenePhase {
                    case .active:
                        handleShortcutAction()
                    case .background:
                        updateShortcuts()
                    default:
                        break
                    }
                }
        }
    }
    
    private func handleConfigurationUniversalLink(_ url: URL) {
        guard let code = extractCodeParameter(from: url) else { return }
        
        guard Preferences.standard.appConfiguration == nil else {
            Logger.main.warning("Application already configured.")
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
    
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == Bundle.main.bundleIdentifier else { return }
        
        guard url.pathComponents.count >= 2 else { return }
        
        guard Actito.shared.isConfigured else {
            Logger.main.warning("Actito is not configured. Skipping deep link...")
            return
        }
        
        // Reset the navigation state before processing the new one.
        appState.showProducts = false
        appState.showEvents = false
        appState.showInbox = false
        appState.showUserProfile = false
        
        switch url.pathComponents[1] {
        case "home":
            appState.contentTab = .home
        case "cart":
            appState.contentTab = .cart
        case "settings":
            appState.contentTab = .settings
        case "products":
            appState.contentTab = .home
            appState.showProducts = true
        case "events":
            appState.contentTab = .home
            appState.showEvents = true
        case "inbox":
            appState.contentTab = .settings
            appState.showInbox = true
        case "profile":
            appState.contentTab = .settings
            appState.showUserProfile = true
        default:
            Logger.main.warning("Unprocessed deep link: \(url)")
        }
    }
    
    private func handleShortcutAction() {
        guard let action = shortcutsService.action else {
            return
        }
        
        Logger.main.info("Handling '\(action.rawValue)' shortcut.")
        shortcutsService.action = nil
        
        guard let url = action.deepLink else {
            return
        }
        
        handleDeepLink(url)
    }
    
    private func updateShortcuts() {
        guard Preferences.standard.introFinished else {
            UIApplication.shared.shortcutItems = nil
            return
        }
        
        var shortcuts: [UIApplicationShortcutItem] = []
        
        if Preferences.standard.storeEnabled {
            shortcuts.append(
                UIApplicationShortcutItem(
                    type: ShortcutAction.cart.rawValue,
                    localizedTitle: String(localized: "shortcut_cart"),
                    localizedSubtitle: nil,
                    icon: .init(systemImageName: "cart.fill")
                )
            )
        }
        
        shortcuts.append(
            UIApplicationShortcutItem(
                type: ShortcutAction.settings.rawValue,
                localizedTitle: String(localized: "shortcut_settings"),
                localizedSubtitle: nil,
                icon: .init(systemImageName: "gear")
            )
        )
        
        shortcuts.append(
            UIApplicationShortcutItem(
                type: ShortcutAction.events.rawValue,
                localizedTitle: String(localized: "shortcut_events"),
                localizedSubtitle: nil,
                icon: .init(systemImageName: "calendar.badge.plus")
            )
        )
        
        UIApplication.shared.shortcutItems = shortcuts
    }
}
