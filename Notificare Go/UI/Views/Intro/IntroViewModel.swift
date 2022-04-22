//
//  IntroViewModel.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 07/04/2022.
//

import Foundation
import CoreLocation
import SwiftUI
import NotificareKit

@MainActor
class IntroViewModel: NSObject, ObservableObject {
    private let locationController = LocationController()
    
    @Published var currentTab = 0
    @Published var showingSettingsPermissionDialog = false
    
    func enableRemoteNotifications() {
        Notificare.shared.push().enableRemoteNotifications { _ in
            // TODO: handle error scenario.
            DispatchQueue.main.async {
                withAnimation {
                    self.currentTab += 1
                }
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
