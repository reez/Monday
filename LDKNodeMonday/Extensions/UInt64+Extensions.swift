//
//  UInt64+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/1/23.
//

import Foundation

extension UInt64 {

    static let satsPerBtc: UInt64 = 1_00_000_000
    static let msatsPerSat: UInt64 = 1_000

    var mSatsAsSats: UInt64 {
        return self >= 1000 ? self / UInt64.msatsPerSat : 0
    }

    var mSatsAsBTC: Double {
        return Double(self.mSatsAsSats) / Double(UInt64.satsPerBtc)
    }

    var satsAsMsats: UInt64 {
        return self * UInt64.msatsPerSat
    }

    var satsAsBTC: Double {
        return Double(self) / Double(UInt64.satsPerBtc)
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

extension UInt64 {
    private var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSeparator = ","
        numberFormatter.generatesDecimalNumbers = false
        
        return numberFormatter
    }
    
    func formattedBip177() -> String {
        if self != .zero && self >= 1_000_000 && self % 1_000_000 == .zero {
            return "\(self / 1_000_000)M"
            
        } else if self != .zero && self % 1_000 == 0 {
            return "\(self / 1_000)K"
        }
        
        return numberFormatter.string(from: NSNumber(value: self)) ?? "0"
    }
}

public enum BitcoinFormatting {
    case satscomma
    case truncated
}
