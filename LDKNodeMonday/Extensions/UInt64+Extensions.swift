//
//  UInt64+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/1/23.
//

import Foundation
import LDKNode

extension UInt64 {

    var mSatsAsSats: UInt64 {
        return self >= 1000 ? self / UInt64(Constants.MSATS_PER_SATS) : 0
    }

    func formattedSatsAsBtc(format: BitcoinFormatting? = .truncated) -> String {
        if self == 0 {
            return "0"
        } else {
            switch format {
            case .satscomma:
                return String(
                    format: "%d.%02d %03d %03d",
                    self / 100_000_000,
                    (self % 100_000_000) / 1_000_000,
                    (self % 1_000_000) / 1_000,
                    self % 1_000
                )
            default:
                let btcAmount = Double(self) / Constants.SATS_PER_BTC
                return btcAmount.formatted(.number.notation(.automatic))
            }
        }
    }

    func formattedSatsAsUSD(price: Double) -> String {
        let btcAmount = Double(self) / Constants.SATS_PER_BTC
        let usdValue = btcAmount * price
        return usdValue.formattedCurrency()
    }

}

public enum BitcoinFormatting {
    case satscomma
    case truncated
}
