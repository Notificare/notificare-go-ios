//
//  Product.swift
//  Actito Go
//
//  Created by Helder Pinhal on 11/03/2022.
//

import Foundation

struct Product: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let imageUrl: String
    let highlighted: Bool
}

extension Product {
    static var sample: Product {
        Product(
            id: UUID().uuidString,
            name: "Headphones",
            description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris ut egestas sem, sit amet semper erat. Nam vel neque est. Mauris id nibh vitae odio elementum sodales a et nisl. Quisque suscipit euismod mauris eu tincidunt. Aliquam in ante sodales, aliquam sapien at, fermentum sapien.",
            price: 300,
            imageUrl: "https://www.sony.pt/image/5d02da5df552836db894cead8a68f5f3",
            highlighted: true
        )
    }
}
