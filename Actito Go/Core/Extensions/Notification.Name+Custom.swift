//
//  Notifications.swift
//  Actito Go
//
//  Created by Helder Pinhal on 04/03/2022.
//

import Foundation

extension Notification.Name {
    // Core
    static let actitoLaunched = Notification.Name(rawValue: "app.actito_launched")

    // Push
    static let notificationSettingsChanged = Notification.Name(rawValue: "app.notification_settings_changed")
    
    // Inbox
    static let badgeUpdated = Notification.Name(rawValue: "app.badge_updated")
    static let inboxUpdated = Notification.Name(rawValue: "app.inbox_updated")
    
    // Geo
    static let beaconsRanged = Notification.Name(rawValue: "app.beacons_ranged")
}
