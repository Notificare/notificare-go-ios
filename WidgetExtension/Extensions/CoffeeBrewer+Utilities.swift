//
//  CoffeeBrewer+Utilities.swift
//  WidgetExtension
//
//  Created by Helder Pinhal on 09/12/2022.
//

import Foundation

extension CoffeeBrewerActivityAttributes.ContentState {
    var localizedTimeRemaining: String {
        let localizationKey = NSLocalizedString("coffee_headline_pick_up_minutes", comment: "")
        return String(format: localizationKey, remaining)
    }
}
