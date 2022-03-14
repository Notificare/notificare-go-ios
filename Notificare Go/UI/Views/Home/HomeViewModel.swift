//
//  HomeView+ViewModel.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 09/03/2022.
//

import Foundation
import NotificareKit
import NotificareAssetsKit
import NotificareScannablesKit

@MainActor
class HomeViewModel: ObservableObject {
    @Published private(set) var highlightedProducts = [Product]()
    
    init() {
        Task {
            do {
                let assets = try await Notificare.shared.assets().fetch(group: "products")
                let productList = assets.first!.extra["products"]
                
                let encoded = try JSONEncoder().encode(AnyCodable(productList))
                let decoded = try JSONDecoder().decode([Product].self, from: encoded)
                
                highlightedProducts = decoded.filter { $0.highlighted }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
