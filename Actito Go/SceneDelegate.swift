//
//  SceneDelegate.swift
//  Actito Go
//
//  Created by Helder Pinhal on 22/06/2022.
//

import Foundation
import UIKit

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    @MainActor
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem) async -> Bool {
        ShortcutsService.shared.action = ShortcutAction(shortcutItem: shortcutItem)
        return true
    }
}
