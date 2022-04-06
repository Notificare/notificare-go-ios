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
