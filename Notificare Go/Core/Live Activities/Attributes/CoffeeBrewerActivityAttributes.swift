//
//  CoffeeBrewerActivityAttributes.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 07/12/2022.
//

import Foundation
import ActivityKit

struct CoffeeBrewerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var state: BrewingState
        var remaining: Int
    }

    public enum BrewingState: String, Codable, CaseIterable {
        case grinding
        case brewing
        case served

        var index: Int {
            guard let index = Self.allCases.firstIndex(of: self) else {
                return 0
            }

            return Self.allCases.distance(
                from: Self.allCases.startIndex,
                to: index
            )
        }
    }
}
