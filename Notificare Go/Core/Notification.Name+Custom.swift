//
//  Notifications.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 04/03/2022.
//

import Foundation

extension Notification.Name {
    // Core
    static let notificareLaunched = Notification.Name(rawValue: "app.notificare_launched")
    
    // Push
    static let notificationSettingsChanged = Notification.Name(rawValue: "app.notification_settings_changed")
    
    // Inbox
    static let badgeUpdated = Notification.Name(rawValue: "app.badge_updated")
    static let inboxUpdated = Notification.Name(rawValue: "app.inbox_updated")
}
