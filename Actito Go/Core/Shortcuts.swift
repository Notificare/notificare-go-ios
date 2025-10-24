//
//  Shortcut.swift
//  Actito Go
//
//  Created by Helder Pinhal on 22/06/2022.
//

import Foundation
import UIKit
import Combine

enum ShortcutAction: String, Equatable {
    case cart
    case settings
    case events
    
    var deepLink: URL? {
        guard let scheme = Bundle.main.bundleIdentifier else {
            return nil
        }
        
        switch self {
        case .cart:
            return URL(string: "\(scheme)://notifica.re/cart")
        case .settings:
            return URL(string: "\(scheme)://notifica.re/settings")
        case .events:
            return URL(string: "\(scheme)://notifica.re/events")
        }
    }
    
    init?(shortcutItem: UIApplicationShortcutItem) {
        guard let action = ShortcutAction(rawValue: shortcutItem.type) else {
            return nil
        }
        
        self = action
    }
}

class ShortcutsService: ObservableObject {
    static let shared = ShortcutsService()
    
    @Published var action: ShortcutAction?
}
