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

    func valueInUSD(price: Double) -> Double {
        let bitcoin = self / 100_000_000.0
        let usdValue = bitcoin * price
        return usdValue
    }

}
