//
//  UInt64+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/1/23.
//

import Foundation

extension UInt64 {

    var mSatsAsSats: UInt64 {
        return self / 1000
    }

    func formattedBtc() -> String {
        if self == 0 {
            return "0.00 000 000"
        } else {
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

            let formattedBalance = "\(formattedZero).\(first) \(second) \(third)"

            return formattedBalance
        }
    }

}
