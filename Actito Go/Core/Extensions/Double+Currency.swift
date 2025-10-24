//
//  Double+Currency.swift
//  Actito Go
//
//  Created by Helder Pinhal on 15/03/2022.
//

import Foundation

extension Double {
    
    func asCurrencyString() -> String {
        let hasCentsAmount = self.truncatingRemainder(dividingBy: 1) != 0
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.currencySymbol = "€"
        formatter.maximumFractionDigits = hasCentsAmount ? 2 : 0
        
        return formatter.string(from: NSNumber(value: self))!
    }
}
