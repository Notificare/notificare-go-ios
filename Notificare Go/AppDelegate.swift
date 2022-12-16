//
//  AppDelegate.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 04/03/2022.
//

import Firebase
import Foundation
import UIKit
import NotificareKit
import NotificareGeoKit
import NotificareInboxKit
import NotificarePushKit
import NotificareScannablesKit
import OSLog

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        #if DEBUG
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
        #else
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        #endif
        
        // Configure Notificare.
        Notificare.shared.push().presentationOptions = [.banner, .badge, .sound]
        
        // Setup the delegates.
        Notificare.shared.delegate = self
        Notificare.shared.push().delegate = self
        Notificare.shared.inbox().delegate = self
        Notificare.shared.geo().delegate = self
        Notificare.shared.scannables().delegate = self
        
        if let configuration = Preferences.standard.appConfiguration {
            Notificare.shared.configure(
                servicesInfo: NotificareServicesInfo(
                    applicationKey: configuration.applicationKey,
                    applicationSecret: configuration.applicationSecret
                )
            )
        }

        if #available(iOS 16.1, *) {
            LiveActivitiesController.shared.startMonitoring()
        }

        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            ShortcutsService.shared.action = ShortcutAction(shortcutItem: shortcutItem)
        }
        
        let configuration = UISceneConfiguration(name: connectingSceneSession.configuration.name, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        
        return configuration
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {}
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {}
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {}
}

extension AppDelegate: NotificareDelegate {
    func notificare(_ notificare: Notificare, onReady application: NotificareApplication) {
        NotificationCenter.default.post(name: .notificareLaunched, object: nil)
        
        if Notificare.shared.push().hasRemoteNotificationsEnabled {
            Notificare.shared.push().enableRemoteNotifications { _ in }
        }
        
        if Notificare.shared.geo().hasLocationServicesEnabled {
            Notificare.shared.geo().enableLocationUpdates()
        }
    }
}

extension AppDelegate: NotificarePushDelegate {
    func notificare(_ notificarePush: NotificarePush, didOpenNotification notification: NotificareNotification) {
        UIApplication.shared.present(notification)
    }
    
    func notificare(_ notificarePush: NotificarePush, didOpenAction action: NotificareNotification.Action, for notification: NotificareNotification) {
        UIApplication.shared.present(action, for: notification)
    }
    
    func notificare(_ notificarePush: NotificarePush, didChangeNotificationSettings granted: Bool) {
        NotificationCenter.default.post(
            name: .notificationSettingsChanged,
            object: nil
        )
    }
}

extension AppDelegate: NotificareInboxDelegate {
    func notificare(_ notificareInbox: NotificareInbox, didUpdateBadge badge: Int) {
        NotificationCenter.default.post(
            name: .badgeUpdated,
            object: nil,
            userInfo: ["badge": badge]
        )
    }
    
    func notificare(_ notificareInbox: NotificareInbox, didUpdateInbox items: [NotificareInboxItem]) {
        NotificationCenter.default.post(
            name: .inboxUpdated,
            object: nil,
            userInfo: ["items": items]
        )
    }
}

extension AppDelegate: NotificareGeoDelegate {
    func notificare(_ notificareGeo: NotificareGeo, didRange beacons: [NotificareBeacon], in region: NotificareRegion) {
        NotificationCenter.default.post(
            name: .beaconsRanged,
            object: nil,
            userInfo: [
                "region": region,
                "beacons": beacons,
            ]
        )
    }
}

extension AppDelegate: NotificareScannablesDelegate {
    func notificare(_ notificareScannables: NotificareScannables, didDetectScannable scannable: NotificareScannable) {
        guard let notification = scannable.notification else {
            Logger.main.warning("Cannot present a scannable without a notification.")
            return
        }
        
        UIApplication.shared.present(notification)
    }
    
    func notificare(_ notificareScannables: NotificareScannables, didInvalidateScannerSession error: Error) {
        Logger.main.error("Scannable session invalidated: \(error.localizedDescription)")
    }
}
