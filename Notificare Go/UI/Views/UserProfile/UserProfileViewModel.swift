//
//  UserProfileViewModel.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 11/03/2022.
//

import Combine
import Foundation
import NotificareKit

@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var profileInformation: [ProfileInformationItem] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Task {
            do {
                let fields = try await Notificare.shared.fetchApplication().userDataFields
                let userData = try await Notificare.shared.device().fetchUserData()
                
                self.profileInformation = fields.map { field in
                    ProfileInformationItem(
                        key: field.key,
                        label: field.label,
                        type: field.type,
                        value: userData[field.key] ?? ""
                    )
                }
                
                startListeningToChanges()
            } catch {
                //
            }
        }
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    private func startListeningToChanges() {
        $profileInformation
            .debounce(for: .seconds(1.5), scheduler: RunLoop.main)
            .sink { profile in
                var userData: [String : String] = [:]
                profile.forEach { userData[$0.key] = $0.value }
                
                Notificare.shared.device().updateUserData(userData) { result in
                    switch result {
                    case .success:
                        print("Updated user data.")
                    case .failure:
                        print("Failed to update user data.")
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    
    struct ProfileInformationItem: Identifiable {
        let id = UUID()
        let key: String
        let label: String
        let type: String
        var value: String
    }
}
