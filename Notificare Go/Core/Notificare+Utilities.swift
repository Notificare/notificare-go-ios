//
//  Notificare+Utilities.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 04/03/2022.
//

import Foundation
import NotificareKit
import NotificareInboxKit

extension NotificareInboxItem: Identifiable {}


extension NotificareEventsModule {
    func logCartUpdated() async throws {
        let cart = Preferences.standard.cart
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
    
    func logPurchase() async throws {
        let cart = Preferences.standard.cart
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
        
        try await logCustom("purchase", data: data)
    }
}
