//
//  Double+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 1/20/24.
//

import Foundation

extension Double {

    func formattedPrice(currencyCode: CurrencyCode) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = currencyCode.rawValue

        return numberFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }

    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()

    func formattedCurrency(code: String = "USD") -> String {
        Self.currencyFormatter.currencyCode = code
        return Self.currencyFormatter.string(from: NSNumber(value: self)) ?? "0"
    }

}
