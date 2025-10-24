//
//  AppDelegate.swift
//  Actito Go
//
//  Created by Helder Pinhal on 04/03/2022.
//

import Firebase
import Foundation
import UIKit
import ActitoKit
import ActitoGeoKit
import ActitoInboxKit
import ActitoPushKit
import ActitoPushUIKit
import OSLog

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()

#if DEBUG
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
#else
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
#endif

        // Configure Actito.
        Actito.shared.push().presentationOptions = [.banner, .badge, .sound]

        // Setup the delegates.
        Actito.shared.delegate = self
        Actito.shared.push().delegate = self
        Actito.shared.pushUI().delegate = self
        Actito.shared.inbox().delegate = self
        Actito.shared.geo().delegate = self

        if let configuration = Preferences.standard.appConfiguration {
            Actito.shared.configure(
                servicesInfo: ActitoServicesInfo(
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

extension AppDelegate: ActitoDelegate {
    func actito(_ actito: Actito, onReady application: ActitoApplication) {
        NotificationCenter.default.post(name: .actitoLaunched, object: nil)
    }
}

extension AppDelegate: ActitoPushDelegate {
    func actito(_ actitoPush: ActitoPush, didOpenNotification notification: ActitoNotification) {
        UIApplication.shared.present(notification)
    }

    func actito(_ actitoPush: ActitoPush, didOpenAction action: ActitoNotification.Action, for notification: ActitoNotification) {
        UIApplication.shared.present(action, for: notification)
    }

    func actito(_ actitoPush: ActitoPush, didChangeNotificationSettings granted: Bool) {
        NotificationCenter.default.post(
            name: .notificationSettingsChanged,
            object: nil
        )
    }
}

extension AppDelegate: ActitoPushUIDelegate {
    func actito(_ actitoPushUI: ActitoPushUI, didReceiveCustomAction url: URL, in action: ActitoNotification.Action, for notification: ActitoNotification) {
        UIApplication.shared.open(url, options: [:]) { opened in
            if !opened {
                Logger.main.warning("Cannot open custom action link that's not supported by the application.")
            }
        }
    }
}

extension AppDelegate: ActitoInboxDelegate {
    func actito(_ actitoInbox: ActitoInbox, didUpdateBadge badge: Int) {
        NotificationCenter.default.post(
            name: .badgeUpdated,
            object: nil,
            userInfo: ["badge": badge]
        )
    }

    func actito(_ actitoInbox: ActitoInbox, didUpdateInbox items: [ActitoInboxItem]) {
        NotificationCenter.default.post(
            name: .inboxUpdated,
            object: nil,
            userInfo: ["items": items]
        )
    }
}

extension AppDelegate: ActitoGeoDelegate {
    func actito(_ actitoGeo: ActitoGeo, didRange beacons: [ActitoBeacon], in region: ActitoRegion) {
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
