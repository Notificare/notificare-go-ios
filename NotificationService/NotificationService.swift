//
//  NotificationService.swift
//  NotificationService
//
//  Created by Helder Pinhal on 13/04/2022.
//

import UserNotifications
import ActitoNotificationServiceExtensionKit

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        ActitoNotificationServiceExtension.handleNotificationRequest(request) { result in
            switch result {
            case let .success(content):
                contentHandler(content)
            case let .failure(error):
                print("Failed to handle the notification request. \(error)")
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
