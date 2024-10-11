//
//  IntroViewModel.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 07/04/2022.
//

import Foundation
import CoreLocation
import SwiftUI
import OSLog
import NotificareKit

@MainActor
class IntroViewModel: NSObject, ObservableObject {
    private let locationController = LocationController()
    
    @Published var currentTab = 0
    @Published var showingSettingsPermissionDialog = false
    
    func enableRemoteNotifications() {
        Task {
            do {
                let result = try await Notificare.shared.push().enableRemoteNotifications()
                withAnimation {
                    self.currentTab += 1
                }
            } catch {
                Logger.main.error("Failed to enable remote notifications: \(error)")
            }
        }
    }
    
    func enableLocationUpdates() {
        Task {
            let result = await locationController.requestPermissions()
            
            switch result {
            case .ok:
                withAnimation {
                    currentTab += 1
                }
            case .denied:
                // In the intro we simply allow the user to move forward.
                withAnimation {
                    currentTab += 1
                }
            case .requiresChangeInSettings:
                showingSettingsPermissionDialog = true
            case .restricted:
                // TODO: handle the restricted scenario.
                // The user cannot change this app’s status, possibly due to active restrictions such as parental controls being in place.
                break
            }
        }
    }
}
