//
//  Notificare+Utilities.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 04/03/2022.
//

import Foundation
import NotificareKit
import NotificareGeoKit
import NotificareInboxKit

extension NotificareInboxItem: Identifiable {}

extension NotificareBeacon: Identifiable {}

extension NotificareEventsModule {
    func logAddToCart(product: Product) async throws {
        let data: NotificareEventData = [
            "product": [
                "id": product.id,
                "name": product.name,
                "price": product.price,
                "price_formatted": product.price.asCurrencyString(),
            ],
        ]
        
        try await logCustom("add_to_cart", data: data)
    }
    
    func logRemoveFromCart(product: Product) async throws {
        let data: NotificareEventData = [
            "product": [
                "id": product.id,
                "name": product.name,
                "price": product.price,
                "price_formatted": product.price.asCurrencyString(),
            ],
        ]
        
        try await logCustom("remove_from_cart", data: data)
    }
    
    func logCartUpdated(cart: [CartEntry]) async throws {
        let total = cart.reduce(0.0, { $0 + $1.product.price })
        
        let data: NotificareEventData = [
            "total_price": total,
            "total_price_formatted": total.asCurrencyString(),
            "total_items": cart.count,
            "products": cart.map { entry in
                [
                    "id": entry.product.id,
                    "name": entry.product.name,
                    "price": entry.product.price,
                    "price_formatted": entry.product.price.asCurrencyString(),
                ]
            },
        ]
        
        try await logCustom("cart_updated", data: data)
    }
    
    func logCartCleared() async throws {
        try await logCustom("cart_cleared")
    }
    
    func logPurchase(products: [Product]) async throws {
        let total = products.reduce(0.0, { $0 + $1.price })
        
        let data: NotificareEventData = [
            "total_price": total,
            "total_price_formatted": total.asCurrencyString(),
            "total_items": products.count,
            "products": products.map { product in
                [
                    "id": product.id,
                    "name": product.name,
                    "price": product.price,
                    "price_formatted": product.price.asCurrencyString(),
                ]
            },
        ]
        
        try await logCustom("purchase", data: data)
    }
    
    func logProductView(_ product: Product) async throws {
        let data: NotificareEventData = [
            "product": [
                "id": product.id,
                "name": product.name,
                "price": product.price,
                "price_formatted": product.price.asCurrencyString(),
            ],
        ]
        
        try await logCustom("product_viewed", data: data)
    }
}
