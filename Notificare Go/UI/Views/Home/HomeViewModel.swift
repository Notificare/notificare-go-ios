//
//  HomeView+ViewModel.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 09/03/2022.
//

import Combine
import CoreLocation
import Foundation
import NotificareKit
import NotificareAssetsKit
import NotificareGeoKit
import NotificareScannablesKit

@MainActor
class HomeViewModel: ObservableObject {
    private let locationService = LocationService()
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var highlightedProducts = [Product]()
    @Published private(set) var rangedBeacons = [NotificareBeacon]()
    @Published private(set) var hasLocationPermissions = false
    @Published var showingSettingsPermissionDialog = false
    
    init() {
        fetchProducts()
        observeRangedBeacons()
        checkLocationPermissions()
    }
    
    private func fetchProducts() {
        Task {
            do {
                let assets = try await Notificare.shared.assets().fetch(group: "products")
                let productList = assets.first!.extra["products"]
                
                let encoded = try JSONEncoder().encode(AnyCodable(productList))
                let decoded = try JSONDecoder().decode([Product].self, from: encoded)
                
                highlightedProducts = decoded.filter { $0.highlighted }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func observeRangedBeacons() {
        NotificationCenter.default.publisher(for: .beaconsRanged)
            .sink { [weak self] notification in
                guard let beacons = notification.userInfo?["beacons"] as? [NotificareBeacon] else {
                    return
                }
                
                self?.rangedBeacons = beacons
            }
            .store(in: &cancellables)
    }
    
    private func checkLocationPermissions() {
        hasLocationPermissions = locationService.authorizationStatus == .authorizedAlways && Notificare.shared.geo().hasLocationServicesEnabled
        
        locationService.authorizationStatusPublisher
            .sink { [weak self] authorizationStatus in
                switch authorizationStatus {
                case .authorizedWhenInUse:
                    Notificare.shared.geo().enableLocationUpdates()
                    self?.locationService.requestAlwaysAuthorization()
                    return
                case .authorizedAlways:
                    Notificare.shared.geo().enableLocationUpdates()
                    self?.hasLocationPermissions = true
                    return
                default:
                    print("Unhandled location authorization status: \(authorizationStatus)")
                }
                
                Notificare.shared.geo().disableLocationUpdates()
                self?.hasLocationPermissions = false
            }
            .store(in: &cancellables)
    }
    
    func enableLocationUpdates() {
        guard locationService.authorizationStatus != .denied else {
            showingSettingsPermissionDialog = true
            return
        }
        
        guard locationService.authorizationStatus == .authorizedWhenInUse || locationService.authorizationStatus == .authorizedAlways else {
            locationService.requestWhenInUseAuthorization()
            return
        }
        
        guard locationService.authorizationStatus == .authorizedAlways else {
            locationService.requestAlwaysAuthorization()
            return
        }
        
        Notificare.shared.geo().enableLocationUpdates()
    }
}
