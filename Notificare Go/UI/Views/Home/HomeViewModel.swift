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
import OSLog
import NotificareGeoKit
import NotificareScannablesKit

@MainActor
class HomeViewModel: ObservableObject {
    private let locationController = LocationController(requestAlwaysAuthorization: false)
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
                self.highlightedProducts = assets
                    .compactMap { (asset) -> Product? in
                        guard let id = asset.extra["id"] as? String,
                              let description = asset.description,
                              // let price = asset.extra["price"] as? Double,
                              let imageUrl = asset.url,
                              let highlighted = asset.extra["highlighted"] as? Bool
                        else { return nil }
                        
                        let price: Double
                        if let parsed = asset.extra["price"] as? Int {
                            price = Double(parsed)
                        } else if let parsed = asset.extra["price"] as? Double {
                            price = parsed
                        } else {
                            return nil
                        }
                        
                        return Product(id: id, name: asset.title, description: description, price: price, imageUrl: imageUrl, highlighted: highlighted)
                    }
                    .filter(\.highlighted)
            } catch {
                Logger.main.error("Error fetching the products. \(error.localizedDescription)")
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
        hasLocationPermissions = locationController.hasGeofencingCapabilities
        
        locationController.onLocationCapabilitiesChanged
            .sink { [weak self] in
                guard let self = self else { return }
                
                self.hasLocationPermissions = self.locationController.hasGeofencingCapabilities
            }
            .store(in: &cancellables)
    }
    
    func enableLocationUpdates() {
        Task {
            // Allow automatic upgrades.
            locationController.requestAlwaysAuthorization = true
            
            let result = await locationController.requestPermissions()
            
            switch result {
            case .ok, .denied, .restricted:
                // Will trigger a capabilities change when executed.
                break
            case .requiresChangeInSettings:
                showingSettingsPermissionDialog = true
            }
            
            // Prevent automatic upgrades afterwards.
            locationController.requestAlwaysAuthorization = true
        }
    }
}
