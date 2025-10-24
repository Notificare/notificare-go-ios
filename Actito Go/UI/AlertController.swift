//
//  AlertInfo.swift
//  Actito Go
//
//  Created by Helder Pinhal on 12/04/2022.
//

import Foundation
import SwiftUI

class AlertController: ObservableObject {
    @Published var info: AlertInfo? = nil
    
    struct AlertInfo: Identifiable {
        let id = UUID()
        
        let alert: Alert
        
        init(_ alert: Alert) {
            self.alert = alert
        }
    }
}

extension AlertController.AlertInfo: Equatable {
    static func == (lhs: AlertController.AlertInfo, rhs: AlertController.AlertInfo) -> Bool {
        lhs.id == rhs.id
    }
}
