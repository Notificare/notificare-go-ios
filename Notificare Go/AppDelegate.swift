//
//  AppDelegate.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 04/03/2022.
//

import Foundation
import UIKit
import NotificareKit
import NotificareGeoKit
import NotificareInboxKit
import NotificarePushKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configure Notificare.
        Notificare.shared.push().presentationOptions = [.banner, .badge, .sound]
        
        // Setup the delegates.
        Notificare.shared.delegate = self
        Notificare.shared.push().delegate = self
        Notificare.shared.inbox().delegate = self
        Notificare.shared.geo().delegate = self
        
        // Fire it up! 🚀
        Notificare.shared.launch()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {}
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {}
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {}
}

extension AppDelegate: NotificareDelegate {
    func notificare(_ notificare: Notificare, onReady application: NotificareApplication) {
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
    
}
