//
//  Product.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 11/03/2022.
//

import Foundation

struct Product: Codable, Identifiable {
    let id: String
    let name: String
    let price: Double
    let imageUrl: String
    let highlighted: Bool
}

extension Product {
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        
        return formatter.string(from: NSNumber(value: price))!
    }
}

#if DEBUG

extension Product {
    static var sample: Product {
        Product(
            id: UUID().uuidString,
            name: "Headphones",
            price: 300,
            imageUrl: "https://www.sony.pt/image/5d02da5df552836db894cead8a68f5f3",
            highlighted: true
        )
    }
}

#endif
