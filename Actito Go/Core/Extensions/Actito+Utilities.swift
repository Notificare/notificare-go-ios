//
//  Actito+Utilities.swift
//  Actito Go
//
//  Created by Helder Pinhal on 04/03/2022.
//

import Foundation
import ActitoKit
import ActitoGeoKit
import ActitoInboxKit

extension ActitoEventsModule {
    
    func logIntroFinished() async throws {
        try await logCustom("intro_finished")
    }
    
    // MARK: Page views
    
    func logPageView(_ page: PageView) async throws {
        try await logCustom("page_viewed.\(page.rawValue)")
    }
    
    // MARK: Cart & Products
    
    func logAddToCart(product: Product) async throws {
        let data: ActitoEventData = [
            "product": transformProduct(product),
        ]
        
        try await logCustom("add_to_cart", data: data)
    }
    
    func logRemoveFromCart(product: Product) async throws {
        let data: ActitoEventData = [
            "product": transformProduct(product),
        ]
        
        try await logCustom("remove_from_cart", data: data)
    }
    
    func logCartUpdated(products: [Product]) async throws {
        let total = products.reduce(0.0, { $0 + $1.price })
        
        let data: ActitoEventData = [
            "total_price": total,
            "total_price_formatted": total.asCurrencyString(),
            "total_items": products.count,
            "products": products.map { transformProduct($0) },
        ]
        
        try await logCustom("cart_updated", data: data)
    }
    
    func logCartCleared() async throws {
        try await logCustom("cart_cleared")
    }
    
    func logPurchase(products: [Product]) async throws {
        let total = products.reduce(0.0, { $0 + $1.price })
        
        let data: ActitoEventData = [
            "total_price": total,
            "total_price_formatted": total.asCurrencyString(),
            "total_items": products.count,
            "products": products.map { transformProduct($0) },
        ]
        
        try await logCustom("purchase", data: data)
    }
    
    func logProductView(_ product: Product) async throws {
        let data: ActitoEventData = [
            "product": transformProduct(product),
        ]
        
        try await logCustom("product_viewed", data: data)
    }
    
    
    private func transformProduct(_ product: Product) -> [String: Any] {
        [
            "id": product.id,
            "name": product.name,
            "price": product.price,
            "price_formatted": product.price.asCurrencyString(),
        ]
    }
}

enum PageView: String {
    case home
    case cart
    case settings
    case inbox
    case userProfile = "user_profile"
    case events
    case products
    case productDetails = "product_details"
}
