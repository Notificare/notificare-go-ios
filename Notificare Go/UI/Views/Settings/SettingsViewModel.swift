//
//  SettingsView+ViewModel.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 02/03/2022.
//

import Combine
import Foundation
import NotificareKit
import NotificareInboxKit
import NotificarePushKit

@MainActor
class SettingsViewModel: ObservableObject {
    @Published private(set) var badge: Int
    @Published var notificationsEnabled: Bool
    @Published var doNotDisturbEnabled: Bool
    @Published var doNotDisturbStart: Date
    @Published var doNotDisturbEnd: Date
    @Published var locationEnabled: Bool = false
    @Published var showingSettingsPermissionDialog = false
    
    private let locationService = LocationService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let notificationsEnabled = Notificare.shared.push().hasRemoteNotificationsEnabled && Notificare.shared.push().allowedUI
        let dnd = Notificare.shared.device().currentDevice?.dnd
        
        self.badge = Notificare.shared.inbox().badge
        self.notificationsEnabled = notificationsEnabled
        self.doNotDisturbEnabled = notificationsEnabled && dnd != nil
        self.doNotDisturbStart = (dnd?.start ?? .defaultStart).date
        self.doNotDisturbEnd = (dnd?.end ?? .defaultEnd).date
        
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
        
        $locationEnabled.sink { enabled in
            guard enabled else {
                Notificare.shared.geo().disableLocationUpdates()
                return
            }
            
            guard self.locationService.authorizationStatus != .denied else {
                self.showingSettingsPermissionDialog = true
                return
            }
            
            guard self.locationService.authorizationStatus == .authorizedWhenInUse || self.locationService.authorizationStatus == .authorizedAlways else {
                self.locationService.requestWhenInUseAuthorization()
                return
            }
            
            guard self.locationService.authorizationStatus == .authorizedAlways else {
                self.locationService.requestAlwaysAuthorization()
                return
            }
            
            Notificare.shared.geo().enableLocationUpdates()
        }
        .store(in: &cancellables)
        
        locationService.authorizationStatusPublisher
            .sink { [weak self] authorizationStatus in
                switch authorizationStatus {
                case .authorizedWhenInUse:
                    Notificare.shared.geo().enableLocationUpdates()
                    self?.locationService.requestAlwaysAuthorization()
                    return
                case .authorizedAlways:
                    Notificare.shared.geo().enableLocationUpdates()
                    self?.locationEnabled = true
                    return
                default:
                    print("Unhandled location authorization status: \(authorizationStatus)")
                }
                
                Notificare.shared.geo().disableLocationUpdates()
                self?.locationEnabled = false
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
