//
//  Double+Currency.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 15/03/2022.
//

import Foundation

extension Double {
    
    func asCurrencyString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.currencySymbol = "EUR"
        
        return formatter.string(from: NSNumber(value: self))!
    }
}
