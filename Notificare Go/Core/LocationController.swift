//
//  LocationController.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 22/04/2022.
//

import Foundation
import Combine
import CoreLocation
import NotificareKit

class LocationController: NSObject, CLLocationManagerDelegate {
    private(set) static var hasRequestedAlwaysPermission = false
    
    private let locationManager: CLLocationManager
    private var requestPermissionsContinuation: CheckedContinuation<RequestLocationResult, Never>? = nil
    
    var requestAlwaysAuthorization: Bool
    let onLocationCapabilitiesChanged = PassthroughSubject<Void, Never>()
    
    var hasLocationTrackingCapabilities: Bool {
        let hasLocationUpdatesEnabled = Notificare.shared.geo().hasLocationServicesEnabled
        let hasLocationPermissions = locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways
        
        return hasLocationUpdatesEnabled && hasLocationPermissions
    }
    
    var hasGeofencingCapabilities: Bool {
        let hasLocationUpdatesEnabled = Notificare.shared.geo().hasLocationServicesEnabled
        let hasAlwaysPermission = locationManager.authorizationStatus == .authorizedAlways
        
        return hasLocationUpdatesEnabled && hasAlwaysPermission
    }
    
    init(requestAlwaysAuthorization: Bool = true) {
        self.locationManager = CLLocationManager()
        self.requestAlwaysAuthorization = requestAlwaysAuthorization
        super.init()
        
        self.locationManager.delegate = self
    }
    
    
    func requestPermissions() async -> RequestLocationResult {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                self.requestPermissionsContinuation = continuation
                self.locationManager.requestWhenInUseAuthorization()
            }
        case .restricted:
            return .restricted
        case .denied:
            return .requiresChangeInSettings
        case .authorizedAlways:
            Notificare.shared.geo().enableLocationUpdates()
            return .ok
        case .authorizedWhenInUse:
            if requestAlwaysAuthorization {
                if LocationController.hasRequestedAlwaysPermission {
                    Notificare.shared.geo().enableLocationUpdates()
                    return .requiresChangeInSettings
                } else {
                    LocationController.hasRequestedAlwaysPermission = true
                    locationManager.requestAlwaysAuthorization()
                    return .ok
                }
            } else {
                if !Notificare.shared.geo().hasLocationServicesEnabled {
                    Notificare.shared.geo().enableLocationUpdates()
                }
                
                return .ok
            }
        case .authorized:
            // Deprecated, not applicable.
            return .ok
        @unknown default:
            return .ok
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            guard Notificare.shared.geo().hasLocationServicesEnabled || requestPermissionsContinuation != nil else {
                print("Received the initial authorization status. Skipping...")
                return
            }
        }
        
        switch manager.authorizationStatus {
        case .denied:
            // To clear the device's location in case one has been acquired.
            Notificare.shared.geo().disableLocationUpdates()
            self.requestPermissionsContinuation?.resume(returning: .denied)
            self.requestPermissionsContinuation = nil
        case .authorizedAlways:
            // Enable geofencing.
            Notificare.shared.geo().enableLocationUpdates()
            self.requestPermissionsContinuation?.resume(returning: .ok)
            self.requestPermissionsContinuation = nil
        case .authorizedWhenInUse:
            // Enable location tracking.
            Notificare.shared.geo().enableLocationUpdates()
            
            if requestAlwaysAuthorization {
                // Try upgrading to always.
                LocationController.hasRequestedAlwaysPermission = true
                locationManager.requestAlwaysAuthorization()
            }
            
            self.requestPermissionsContinuation?.resume(returning: .ok)
            self.requestPermissionsContinuation = nil
        default:
            self.requestPermissionsContinuation?.resume(returning: .ok)
            self.requestPermissionsContinuation = nil
        }
        
        self.onLocationCapabilitiesChanged.send()
    }
    
    enum RequestLocationResult {
        case ok
        case denied
        case restricted
        case requiresChangeInSettings
    }
}
