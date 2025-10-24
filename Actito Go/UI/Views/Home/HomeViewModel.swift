//
//  HomeView+ViewModel.swift
//  Actito Go
//
//  Created by Helder Pinhal on 09/03/2022.
//

import Combine
import CoreLocation
import Foundation
import ActitoKit
import ActitoAssetsKit
import OSLog
import ActitoGeoKit
import ActivityKit
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    private let locationController = LocationController(requestAlwaysAuthorization: false)
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var highlightedProducts = [Product]()
    @Published private(set) var rangedBeacons = [ActitoBeacon]()
    @Published private(set) var hasLocationPermissions = false
    @Published var showingSettingsPermissionDialog = false
    @Published private(set) var coffeeBrewerLiveActivityState: CoffeeBrewerActivityAttributes.BrewingState?
    
    init() {
        fetchProducts()
        observeRangedBeacons()
        checkLocationPermissions()

        if #available(iOS 16.1, *) {
            monitorLiveActivities()
        }
    }
    
    private func fetchProducts() {
        Task {
            do {
                let assets = try await Actito.shared.assets().fetch(group: "products")
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
                guard let beacons = notification.userInfo?["beacons"] as? [ActitoBeacon] else {
                    return
                }
                
                self?.rangedBeacons = beacons
            }
            .store(in: &cancellables)
    }
    
    private func checkLocationPermissions() {
        hasLocationPermissions = locationController.hasGeofencingCapabilities

        locationController.onLocationCapabilitiesChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                
                self.hasLocationPermissions = self.locationController.hasGeofencingCapabilities
            }
            .store(in: &cancellables)
    }

    @available(iOS 16.1, *)
    private func monitorLiveActivities() {
        withAnimation {
            // Load the initial state.
            coffeeBrewerLiveActivityState = Activity<CoffeeBrewerActivityAttributes>.activities.first?.contentState.state
        }

        Task {
            // Listen to on-going and new Live Activities.
            for await activity in Activity<CoffeeBrewerActivityAttributes>.activityUpdates {
                Task {
                    // Listen to state changes of each activity.
                    for await state in activity.activityStateUpdates {
                        Logger.main.debug("Live activity '\(activity.id)' state = '\(String(describing: state))'")

                        switch activity.activityState {
                        case .active:
                            Task {
                                // Listen to content updates of each active activity.
                                for await state in activity.contentStateUpdates {
                                    withAnimation {
                                        coffeeBrewerLiveActivityState = state.state
                                    }
                                }
                            }

                        case .dismissed, .ended:
                            // Reset the UI controls.
                            coffeeBrewerLiveActivityState = nil

                        @unknown default:
                            Logger.main.warning("Live activity '\(activity.id)' unknown state '\(String(describing: state))'.")
                        }
                    }
                }
            }
        }
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
