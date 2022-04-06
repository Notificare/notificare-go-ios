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
                    let entry = Preferences.standard.cart.remove(at: index)
                    try await Notificare.shared.events().logRemoveFromCart(product: entry.product)
                }
                
                try await Notificare.shared.events().logCartUpdated(cart: Preferences.standard.cart)
                try await Notificare.shared.events().logCartCleared()
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
                let products = Preferences.standard.cart.map { $0.product }
                Preferences.standard.cart.removeAll()
                
                try await Notificare.shared.events().logCartCleared()
                try await Notificare.shared.events().logPurchase(products: products)
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
