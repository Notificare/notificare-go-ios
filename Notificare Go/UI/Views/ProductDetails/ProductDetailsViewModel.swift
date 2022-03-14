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
    
    func addToCart(_ product: Product) {
        Task {
            do {
                let data: NotificareEventData = [
                    "total_price": 300,
                    "total_price_formatted": "€300,00",
                    "total_items": 10,
                    "products": [
                        [
                            "id": product.id,
                            "name": product.name,
                            "price": product.price,
                            "price_formatted": product.formattedPrice,
                        ],
                    ],
                ]
                
                try await Notificare.shared.events().logCustom("cart_updated", data: data)
            } catch {
                // TODO: handle the error.
            }
        }
    }
}
