//
//  LocationController.swift
//  Actito Go
//
//  Created by Helder Pinhal on 22/04/2022.
//

import Foundation
import Combine
import CoreLocation
import ActitoKit
import OSLog


class LocationController: NSObject, CLLocationManagerDelegate {
    private(set) static var hasRequestedAlwaysPermission = false
    
    private let locationManager: CLLocationManager
    private var requestPermissionsContinuation: CheckedContinuation<RequestLocationResult, Never>? = nil
    
    var requestAlwaysAuthorization: Bool
    let onLocationCapabilitiesChanged = PassthroughSubject<Void, Never>()

    @MainActor
    var hasLocationTrackingCapabilities: Bool {
        let hasLocationUpdatesEnabled = Actito.shared.geo().hasLocationServicesEnabled
        let hasLocationPermissions = locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways
        
        return hasLocationUpdatesEnabled && hasLocationPermissions
    }

    @MainActor
    var hasGeofencingCapabilities: Bool {
        let hasLocationUpdatesEnabled = Actito.shared.geo().hasLocationServicesEnabled
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
            await Actito.shared.geo().enableLocationUpdates()
            return .ok
        case .authorizedWhenInUse:
            if requestAlwaysAuthorization {
                if LocationController.hasRequestedAlwaysPermission {
                    await Actito.shared.geo().enableLocationUpdates()
                    return .requiresChangeInSettings
                } else {
                    LocationController.hasRequestedAlwaysPermission = true
                    locationManager.requestAlwaysAuthorization()
                    return .ok
                }
            } else {
                let hasLocationServicesEnabled = await Actito.shared.geo().hasLocationServicesEnabled
                if !hasLocationServicesEnabled {
                    await Actito.shared.geo().enableLocationUpdates()
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
        Task {
            if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
                guard await Actito.shared.geo().hasLocationServicesEnabled || requestPermissionsContinuation != nil else {
                    Logger.main.info("Received the initial authorization status. Skipping...")
                    return
                }
            }

            switch manager.authorizationStatus {
            case .denied:
                // To clear the device's location in case one has been acquired.
                await Actito.shared.geo().disableLocationUpdates()
                self.requestPermissionsContinuation?.resume(returning: .denied)
                self.requestPermissionsContinuation = nil
            case .authorizedAlways:
                // Enable geofencing.
                await Actito.shared.geo().enableLocationUpdates()
                self.requestPermissionsContinuation?.resume(returning: .ok)
                self.requestPermissionsContinuation = nil
            case .authorizedWhenInUse:
                // Enable location tracking.
                await Actito.shared.geo().enableLocationUpdates()

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
    }
    
    enum RequestLocationResult {
        case ok
        case denied
        case restricted
        case requiresChangeInSettings
    }
}
