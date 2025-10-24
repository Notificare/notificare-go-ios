//
//  SettingsView+ViewModel.swift
//  Actito Go
//
//  Created by Helder Pinhal on 02/03/2022.
//

import Combine
import Foundation
import FirebaseAuth
import ActitoKit
import ActitoInboxKit
import ActitoPushKit
import SwiftUI
import OSLog

@MainActor
class SettingsViewModel: ObservableObject {
    @Published private(set) var badge: Int
    @Published var notificationsEnabled: Bool
    @Published var doNotDisturbEnabled: Bool
    @Published var doNotDisturbStart: Date
    @Published var doNotDisturbEnd: Date
    @Published var locationEnabled: Bool
    @Published var showingSettingsPermissionDialog = false
    // Tags section
    @Published var announcementsTagEnabled = false
    @Published var marketingTagEnabled = false
    @Published var bestPracticesTagEnabled = false
    @Published var productUpdatesTagEnabled = false
    @Published var engineeringTagEnabled = false
    @Published var staffTagEnabled = false
    
    private let locationController = LocationController(requestAlwaysAuthorization: false)
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let notificationsEnabled = Actito.shared.push().hasRemoteNotificationsEnabled && Actito.shared.push().allowedUI
        let dnd = Actito.shared.device().currentDevice?.dnd

        self.badge = Actito.shared.inbox().badge
        self.notificationsEnabled = notificationsEnabled
        self.doNotDisturbEnabled = notificationsEnabled && dnd != nil
        self.doNotDisturbStart = (dnd?.start ?? .defaultStart).date
        self.doNotDisturbEnd = (dnd?.end ?? .defaultEnd).date
        
        self.locationEnabled = locationController.hasLocationTrackingCapabilities

        NotificationCenter.default
            .publisher(for: .badgeUpdated, object: nil)
            .sink { [weak self] notification in
                guard let badge = notification.userInfo?["badge"] as? Int else {
                    Logger.main.error("Invalid notification payload.")
                    return
                }
                
                self?.badge = badge
            }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: .notificationSettingsChanged, object: nil)
            .sink { [weak self] _ in
                let enabled = Actito.shared.push().hasRemoteNotificationsEnabled && Actito.shared.push().allowedUI

                if self?.notificationsEnabled != enabled { self?.notificationsEnabled = enabled }
            }
            .store(in: &cancellables)
        
        $notificationsEnabled
            .dropFirst()
            .sink { enabled in
                Task {
                    if enabled {
                        do {
                            _ = try await Actito.shared.push().enableRemoteNotifications()
                        } catch {
                            Logger.main.error("Failed to enable remote notifications.")
                        }
                    } else {
                        do {
                            try await Actito.shared.push().disableRemoteNotifications()
                        } catch {
                            Logger.main.error("Failed to disable remote notifications.")
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        $doNotDisturbEnabled
            .dropFirst()
            .sink { [weak self] enabled in
                guard let self = self else { return }
                
                if enabled {
                    let dnd = ActitoDoNotDisturb(
                        start: ActitoTime(from: self.doNotDisturbStart),
                        end: ActitoTime(from: self.doNotDisturbEnd)
                    )
                    
                    Actito.shared.device().updateDoNotDisturb(dnd) { _ in }
                } else {
                    Actito.shared.device().clearDoNotDisturb { _ in }
                }
            }
            .store(in: &cancellables)
        
        $doNotDisturbStart
            .dropFirst()
            .sink { [weak self] start in
                guard let self = self else { return }
                
                let dnd = ActitoDoNotDisturb(
                    start: ActitoTime(from: start),
                    end: ActitoTime(from: self.doNotDisturbEnd)
                )
                
                Actito.shared.device().updateDoNotDisturb(dnd) { _ in }
            }
            .store(in: &cancellables)
        
        $doNotDisturbEnd
            .dropFirst()
            .sink { [weak self] end in
                guard let self = self else { return }
                
                let dnd = ActitoDoNotDisturb(
                    start: ActitoTime(from: self.doNotDisturbStart),
                    end: ActitoTime(from: end)
                )
                
                Actito.shared.device().updateDoNotDisturb(dnd) { _ in }
            }
            .store(in: &cancellables)
        
        $locationEnabled
            .dropFirst()
            .sink { enabled in
                guard enabled else {
                    Actito.shared.geo().disableLocationUpdates()
                    return
                }
                
                Task {
                    let result = await self.locationController.requestPermissions()
                    
                    switch result {
                    case .ok, .denied, .restricted:
                        // Will trigger a capabilities change when executed.
                        break
                    case .requiresChangeInSettings:
                        self.showingSettingsPermissionDialog = true
                    }
                }
            }
            .store(in: &self.cancellables)
        
        
        locationController.onLocationCapabilitiesChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.locationEnabled = self?.locationController.hasLocationTrackingCapabilities ?? false
            }
            .store(in: &cancellables)
        
        Task {
            await loadDeviceTags()
            observeTagChanges()
        }
    }
    
    private func loadDeviceTags() async {
        do {
            let tags = try await Actito.shared.device().fetchTags()

            announcementsTagEnabled = tags.contains("topic_announcements")
            marketingTagEnabled = tags.contains("topic_marketing")
            bestPracticesTagEnabled = tags.contains("topic_best_practices")
            productUpdatesTagEnabled = tags.contains("topic_product_updates")
            engineeringTagEnabled = tags.contains("topic_engineering")
            staffTagEnabled = tags.contains("topic_staff")
        } catch {
            Logger.main.error("Failed to fetch device tags. \(error.localizedDescription)")
        }
    }
    
    private func observeTagChanges() {
        $announcementsTagEnabled
            .dropFirst()
            .sink { enabled in
                Task {
                    do {
                        if enabled {
                            try await Actito.shared.device().addTag("topic_announcements")
                        } else {
                            try await Actito.shared.device().removeTag("topic_announcements")
                        }
                    } catch {
                        withAnimation { [weak self] in
                            // Revert the change if the request failed.
                            self?.announcementsTagEnabled = !enabled
                        }
                    }
                }
            }
            .store(in: &cancellables)

        $marketingTagEnabled
            .dropFirst()
            .sink { enabled in
                Task {
                    do {
                        if enabled {
                            try await Actito.shared.device().addTag("topic_marketing")
                        } else {
                            try await Actito.shared.device().removeTag("topic_marketing")
                        }
                    } catch {
                        withAnimation { [weak self] in
                            // Revert the change if the request failed.
                            self?.marketingTagEnabled = !enabled
                        }
                    }
                }
            }
            .store(in: &cancellables)

        $bestPracticesTagEnabled
            .dropFirst()
            .sink { enabled in
                Task {
                    do {
                        if enabled {
                            try await Actito.shared.device().addTag("topic_best_practices")
                        } else {
                            try await Actito.shared.device().removeTag("topic_best_practices")
                        }
                    } catch {
                        withAnimation { [weak self] in
                            // Revert the change if the request failed.
                            self?.bestPracticesTagEnabled = !enabled
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        $productUpdatesTagEnabled
            .dropFirst()
            .sink { enabled in
                Task {
                    do {
                        if enabled {
                            try await Actito.shared.device().addTag("topic_product_updates")
                        } else {
                            try await Actito.shared.device().removeTag("topic_product_updates")
                        }
                    } catch {
                        withAnimation { [weak self] in
                            // Revert the change if the request failed.
                            self?.productUpdatesTagEnabled = !enabled
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        $engineeringTagEnabled
            .dropFirst()
            .sink { enabled in
                Task {
                    do {
                        if enabled {
                            try await Actito.shared.device().addTag("topic_engineering")
                        } else {
                            try await Actito.shared.device().removeTag("topic_engineering")
                        }
                    } catch {
                        withAnimation { [weak self] in
                            // Revert the change if the request failed.
                            self?.engineeringTagEnabled = !enabled
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        $staffTagEnabled
            .dropFirst()
            .sink { enabled in
                Task {
                    do {
                        if enabled {
                            try await Actito.shared.device().addTag("topic_staff")
                        } else {
                            try await Actito.shared.device().removeTag("topic_staff")
                        }
                    } catch {
                        withAnimation { [weak self] in
                            // Revert the change if the request failed.
                            self?.staffTagEnabled = !enabled
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
}

private extension ActitoTime {
    init(from date: Date) {
        let hours = Calendar.current.component(.hour, from: date)
        let minutes = Calendar.current.component(.minute, from: date)
        
        try! self.init(hours: hours, minutes: minutes)
    }
    
    var date: Date {
        Calendar.current.date(bySettingHour: hours, minute: minutes, second: 0, of: Date())!
    }
    
    static var defaultStart: ActitoTime {
        try! ActitoTime(hours: 23, minutes: 0)
    }
    
    static var defaultEnd: ActitoTime {
        try! ActitoTime(hours: 8, minutes: 0)
    }
}
