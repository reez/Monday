//
//  UInt64+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/1/23.
//

import Foundation

extension UInt64 {

    var mSatsAsSats: UInt64 {
        return self >= 1000 ? self / 1000 : 0
    }

    func formattedSatsAsBtc(format: BitcoinFormatting? = .truncated) -> String {
        if self == 0 {
            return "0"
        } else {
            switch format {
            case .satscomma:
                let balanceString = String(format: "%010d", self)

                let zero = balanceString.prefix(2)
                let first = balanceString.dropFirst(2).prefix(2)
                let second = balanceString.dropFirst(4).prefix(3)
                let third = balanceString.dropFirst(7).prefix(3)

                var formattedZero = zero

                if zero == "00" {
                    formattedZero = zero.dropFirst()
                } else if zero.hasPrefix("0") {
                    formattedZero = zero.suffix(1)
                }

                return "\(formattedZero).\(first) \(second) \(third)"
            default:
                let btcAmount = Double(self) / 1_00_000_000.0
                return btcAmount.formatted(.number.notation(.automatic))
            }

        }
    }

    func formattedSatsAsUSD(price: Double) -> String {
        let btcAmount = Double(self) / 1_00_000_000.0
        let usdValue = btcAmount * price

        if usdValue == 0 {
            return usdValue.formattedCurrency()
        } else {
            return usdValue.formattedCurrency()
        }
    }

}

public enum BitcoinFormatting {
    case satscomma
    case truncated
}
