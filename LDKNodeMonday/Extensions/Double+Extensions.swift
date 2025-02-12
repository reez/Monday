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

    func formattedUSD(price: Double) -> String {
        let bitcoin = self / 100_000_000.0
        let usdValue = bitcoin * price

        // Format the value based on its value
        if usdValue == 0 {
            return formattedCurrency(value: 0)
        } else {
            return formattedCurrency(value: usdValue)
        }
    }

    private func formattedCurrency(value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"  // Change if supporting other fiat currencies
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0

        // Return localised
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }

}
