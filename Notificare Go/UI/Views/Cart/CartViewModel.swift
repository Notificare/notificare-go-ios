//
//  CartViewModel.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 15/03/2022.
//

import Foundation
import NotificareKit

@MainActor
class CartViewModel: ObservableObject {
    @Published private(set) var purchaseCommand: PurchaseCommand = .na
    
    func remove(_ entry: CartEntry) {
        Task {
            do {
                if let index = Preferences.standard.cart.firstIndex(where: { $0.id == entry.id }) {
                    Preferences.standard.cart.remove(at: index)
                }
                
                try await Notificare.shared.events().logCartUpdated()
            } catch {
                //
            }
        }
    }
    
    func purchase() {
        Task {
            purchaseCommand = .loading
            
            // Delay the task between 0.5 and 1 second.
            try? await Task.sleep(nanoseconds: .random(in: 500_000_000...1_000_000_000))
            
            do {
                Preferences.standard.cart.removeAll()
                
                try await Notificare.shared.events().logPurchase()
                purchaseCommand = .success
            } catch {
                purchaseCommand = .failure
            }
        }
    }
    
    enum PurchaseCommand {
        case na
        case loading
        case success
        case failure
    }
}
