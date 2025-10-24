//
//  ProductDetailsViewModel.swift
//  Actito Go
//
//  Created by Helder Pinhal on 14/03/2022.
//

import Foundation
import ActitoKit

@MainActor
class ProductDetailsViewModel: ObservableObject {
    let product: Product
    
    @Published private(set) var cartCommand: CartCommand = .na
    
    init(product: Product) {
        self.product = product
        
        Task {
            do {
                try await Actito.shared.events().logProductView(product)
            } catch {
                //
            }
        }
    }
    
    func addToCart() {
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
                
                let entries = Preferences.standard.cart
                try await Actito.shared.events().logAddToCart(product: product)
                try await Actito.shared.events().logCartUpdated(products: entries.map { $0.product })
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
