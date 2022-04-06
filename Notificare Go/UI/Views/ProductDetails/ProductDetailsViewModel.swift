//
//  ProductDetailsViewModel.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 14/03/2022.
//

import Foundation
import NotificareKit

@MainActor
class ProductDetailsViewModel: ObservableObject {
    @Published private(set) var cartCommand: CartCommand = .na
    
    func addToCart(_ product: Product) {
        Task {
            cartCommand = .loading
            
            // Delay the task between 0.5 and 1 second.
            try? await Task.sleep(nanoseconds: .random(in: 500_000_000...1_000_000_000))
            
            do {
                // Store the entry in the local cart.
                Preferences.standard.cart.append(
                    CartEntry(
                        id: UUID(),
                        time: Date(),
                        product: product
                    )
                )
                
                try await Notificare.shared.events().logCartUpdated()
                cartCommand = .success
            } catch {
                cartCommand = .failure
            }
        }
    }
    
    enum CartCommand {
        case na
        case loading
        case success
        case failure
    }
}
