//
//  ProductsListViewModel.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 14/03/2022.
//

import Foundation
import NotificareKit

@MainActor
class ProductsListViewModel: ObservableObject {
    @Published private(set) var products = [Product]()
    
    init() {
        fetchProducts()
    }
    
    private func fetchProducts() {
        Task {
            do {
                let assets = try await Notificare.shared.assets().fetch(group: "products")
                self.products = assets.compactMap { (asset) -> Product? in
                    guard let id = asset.extra["id"] as? String,
                          let description = asset.description,
                          // let price = asset.extra["price"] as? Double,
                          let imageUrl = asset.url,
                          let highlighted = asset.extra["highlighted"] as? Bool
                    else { return nil }
                    
                    let price: Double
                    if let parsed = asset.extra["price"] as? Int {
                        price = Double(parsed)
                    } else if let parsed = asset.extra["price"] as? Double {
                        price = parsed
                    } else {
                        return nil
                    }
                    
                    return Product(id: id, name: asset.title, description: description, price: price, imageUrl: imageUrl, highlighted: highlighted)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
