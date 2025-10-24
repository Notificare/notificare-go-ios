//
//  CartEntry.swift
//  Actito Go
//
//  Created by Helder Pinhal on 15/03/2022.
//

import Foundation

struct CartEntry: Codable, Identifiable {
    let id: UUID
    let time: Date
    let product: Product
}
