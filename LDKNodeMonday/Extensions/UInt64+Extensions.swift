//
//  UInt64+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/1/23.
//

import Foundation
import LDKNode

extension UInt64 {

    static let satsPerBtc: UInt64 = 1_00_000_000
    static let msatsPerSat: UInt64 = 1_000

    var mSatsAsSats: UInt64 {
        return self >= 1000 ? self / UInt64.msatsPerSat : 0
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
                let btcAmount = Double(self) / Double(UInt64.satsPerBtc)
                return btcAmount.formatted(.number.notation(.automatic))
            }
        }
    }

    func formattedSatsAsUSD(price: Double) -> String {
        let btcAmount = Double(self) / Double(UInt64.satsPerBtc)
        let usdValue = btcAmount * price
        return usdValue.formattedCurrency()
    }

}

public enum BitcoinFormatting {
    case satscomma
    case truncated
}
