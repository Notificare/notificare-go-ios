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
    private let locationManager = CLLocationManager()
    @Published var currentTab = 0
    @Published var showingSettingsPermissionDialog = false
    
    func enableRemoteNotifications() {
        Notificare.shared.push().enableRemoteNotifications { _ in
            // TODO: handle error scenario.
            withAnimation {
                self.currentTab += 1
            }
        }
    }
    
    func enableLocationUpdates() {
        locationManager.delegate = self
        
        let authorizationStatus = locationManager.authorizationStatus
        
        guard authorizationStatus != .denied else {
            showingSettingsPermissionDialog = true
            return
        }
        
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        guard authorizationStatus == .authorizedAlways else {
            locationManager.requestAlwaysAuthorization()
            return
        }
        
        Notificare.shared.geo().enableLocationUpdates()
    }
}

extension IntroViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            Notificare.shared.geo().enableLocationUpdates()
            manager.requestAlwaysAuthorization()
            return
        case .authorizedAlways:
            Notificare.shared.geo().enableLocationUpdates()
        default:
            print("Unhandled location authorization status: \(manager.authorizationStatus)")
        }
        
        withAnimation {
            self.currentTab += 1
        }
    }
}
