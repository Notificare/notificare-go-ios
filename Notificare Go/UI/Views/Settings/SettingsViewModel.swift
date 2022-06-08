//
//  SettingsView+ViewModel.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 02/03/2022.
//

import Combine
import Foundation
import FirebaseAuth
import NotificareKit
import NotificareInboxKit
import NotificarePushKit
import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    @Published private(set) var user: UserInfo
    @Published private(set) var badge: Int
    @Published var notificationsEnabled: Bool
    @Published var doNotDisturbEnabled: Bool
    @Published var doNotDisturbStart: Date
    @Published var doNotDisturbEnd: Date
    @Published var locationEnabled: Bool
    @Published var showingSettingsPermissionDialog = false
    // Tags section
    @Published var announcementsTagEnabled = false
    @Published var bestPracticesTagEnabled = false
    @Published var productUpdatesTagEnabled = false
    @Published var engineeringTagEnabled = false
    @Published var staffTagEnabled = false
    
    private let locationController = LocationController(requestAlwaysAuthorization: false)
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.user = UserInfo(user: Auth.auth().currentUser!)

//        if let user = Auth.auth().currentUser {
//            self.user = UserInfo(user: user)
//        } else {
//            #if DEBUG
//            self.user = UserInfo(id: "...", name: "John Doe", pictureUrl: nil)
//            #else
//            fatalError("Missing user information.")
//            #endif
//        }
        
        let notificationsEnabled = Notificare.shared.push().hasRemoteNotificationsEnabled && Notificare.shared.push().allowedUI
        let dnd = Notificare.shared.device().currentDevice?.dnd
        
        self.badge = Notificare.shared.inbox().badge
        self.notificationsEnabled = notificationsEnabled
        self.doNotDisturbEnabled = notificationsEnabled && dnd != nil
        self.doNotDisturbStart = (dnd?.start ?? .defaultStart).date
        self.doNotDisturbEnd = (dnd?.end ?? .defaultEnd).date
        
        self.locationEnabled = locationController.hasLocationTrackingCapabilities
        
        NotificationCenter.default
            .publisher(for: .badgeUpdated, object: nil)
            .sink { [weak self] notification in
                guard let badge = notification.userInfo?["badge"] as? Int else {
                    print("Invalid notification payload.")
                    return
                }
                
                self?.badge = badge
            }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: .notificationSettingsChanged, object: nil)
            .sink { [weak self] _ in
                self?.notificationsEnabled = Notificare.shared.push().hasRemoteNotificationsEnabled && Notificare.shared.push().allowedUI
            }
            .store(in: &cancellables)
        
        $notificationsEnabled.sink { enabled in
            if enabled {
                Notificare.shared.push().enableRemoteNotifications { _ in }
            } else {
                Notificare.shared.push().disableRemoteNotifications()
            }
        }
        .store(in: &cancellables)
        
        $doNotDisturbEnabled.sink { [weak self] enabled in
            guard let self = self else { return }
            
            if enabled {
                let dnd = NotificareDoNotDisturb(
                    start: NotificareTime(from: self.doNotDisturbStart),
                    end: NotificareTime(from: self.doNotDisturbEnd)
                )
                
                Notificare.shared.device().updateDoNotDisturb(dnd) { _ in }
            } else {
                Notificare.shared.device().clearDoNotDisturb { _ in }
            }
        }
        .store(in: &cancellables)
        
        $doNotDisturbStart.sink { [weak self] start in
            guard let self = self else { return }
            
            let dnd = NotificareDoNotDisturb(
                start: NotificareTime(from: start),
                end: NotificareTime(from: self.doNotDisturbEnd)
            )
            
            Notificare.shared.device().updateDoNotDisturb(dnd) { _ in }
        }
        .store(in: &cancellables)
        
        $doNotDisturbEnd.sink { [weak self] end in
            guard let self = self else { return }
            
            let dnd = NotificareDoNotDisturb(
                start: NotificareTime(from: self.doNotDisturbStart),
                end: NotificareTime(from: end)
            )
            
            Notificare.shared.device().updateDoNotDisturb(dnd) { _ in }
        }
        .store(in: &cancellables)
        
        $locationEnabled
            .dropFirst()
            .sink { enabled in
                guard enabled else {
                    Notificare.shared.geo().disableLocationUpdates()
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
            let tags = try await Notificare.shared.device().fetchTags()
            
            announcementsTagEnabled = tags.contains("topic_announcements")
            bestPracticesTagEnabled = tags.contains("topic_best_practices")
            productUpdatesTagEnabled = tags.contains("topic_product_updates")
            engineeringTagEnabled = tags.contains("topic_engineering")
            staffTagEnabled = tags.contains("topic_staff")
        } catch {
            print("Failed to fetch device tags. \(error)")
        }
    }
    
    private func observeTagChanges() {
        $announcementsTagEnabled
            .sink { enabled in
                Task {
                    do {
                        if enabled {
                            try await Notificare.shared.device().addTag("topic_announcements")
                        } else {
                            try await Notificare.shared.device().removeTag("topic_announcements")
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
        
        $bestPracticesTagEnabled
            .sink { enabled in
                Task {
                    do {
                        if enabled {
                            try await Notificare.shared.device().addTag("topic_best_practices")
                        } else {
                            try await Notificare.shared.device().removeTag("topic_best_practices")
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
            .sink { enabled in
                Task {
                    do {
                        if enabled {
                            try await Notificare.shared.device().addTag("topic_product_updates")
                        } else {
                            try await Notificare.shared.device().removeTag("topic_product_updates")
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
            .sink { enabled in
                Task {
                    do {
                        if enabled {
                            try await Notificare.shared.device().addTag("topic_engineering")
                        } else {
                            try await Notificare.shared.device().removeTag("topic_engineering")
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
            .sink { enabled in
                Task {
                    do {
                        if enabled {
                            try await Notificare.shared.device().addTag("topic_staff")
                        } else {
                            try await Notificare.shared.device().removeTag("topic_staff")
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

private extension NotificareTime {
    init(from date: Date) {
        let hours = Calendar.current.component(.hour, from: date)
        let minutes = Calendar.current.component(.minute, from: date)
        
        try! self.init(hours: hours, minutes: minutes)
    }
    
    var date: Date {
        Calendar.current.date(bySettingHour: hours, minute: minutes, second: 0, of: Date())!
    }
    
    static var defaultStart: NotificareTime {
        try! NotificareTime(hours: 23, minutes: 0)
    }
    
    static var defaultEnd: NotificareTime {
        try! NotificareTime(hours: 8, minutes: 0)
    }
}
