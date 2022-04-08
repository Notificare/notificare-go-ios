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
                let productList = assets.first!.extra["products"]
                
                let encoded = try JSONEncoder().encode(AnyCodable(productList))
                products = try JSONDecoder().decode([Product].self, from: encoded)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
