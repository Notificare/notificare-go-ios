//
//  OrderLiveActivityAttributes.swift
//  Actito Go
//
//  Created by Helder Pinhal on 29/09/2022.
//

import Foundation
import ActivityKit

public struct OrderActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var state: OrderState
    }

    let products: [Product]

    public enum OrderState: String, Codable, CaseIterable {
        case preparing
        case shipped
        case delivered

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
