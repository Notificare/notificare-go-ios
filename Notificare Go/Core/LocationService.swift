//
//  LocationService.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 07/04/2022.
//

import Combine
import CoreLocation
import NotificareKit

class LocationService: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }
    
    let authorizationStatusPublisher = PassthroughSubject<CLAuthorizationStatus, Never>()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatusPublisher.send(manager.authorizationStatus)
    }
}
