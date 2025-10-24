//
//  UIApplication+TopViewController.swift
//  Actito Go
//
//  Created by Helder Pinhal on 07/03/2022.
//

import Foundation
import UIKit
import ActitoKit
import ActitoPushUIKit

extension UIApplication {
    @MainActor
    var currentKeyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            //.filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
    }

    @MainActor
    var rootViewController: UIViewController? {
        currentKeyWindow?.rootViewController
    }

    @MainActor
    func present(_ notification: ActitoNotification) {
        guard let rootViewController = rootViewController else {
            return
        }

        if !notification.requiresViewController {
            Actito.shared.pushUI().presentNotification(notification, in: rootViewController)
            return
        }
        
        let navigationController = UINavigationController()
        navigationController.view.backgroundColor = .systemBackground
        
        rootViewController.present(navigationController, animated: true) {
            Actito.shared.pushUI().presentNotification(notification, in: navigationController)
        }
    }

    @MainActor
    func present(_ action: ActitoNotification.Action, for notification: ActitoNotification) {
        guard let rootViewController = rootViewController else {
            return
        }
        
        Actito.shared.pushUI().presentAction(action, for: notification, in: rootViewController)
    }
}
