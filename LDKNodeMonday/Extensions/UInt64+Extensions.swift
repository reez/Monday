//
//  UInt64+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/1/23.
//

import Foundation

extension UInt64 {
    func formattedAmount() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSize = 3

        if let formattedNumber = formatter.string(from: NSNumber(value: self)) {
            return formattedNumber
        } else {
            return ""
        }
    }
}
