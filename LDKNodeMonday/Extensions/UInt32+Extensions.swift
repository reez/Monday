//
//  UInt32+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 1/18/24.
//

import Foundation

extension UInt32 {
    func formattedAmount() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSize = 3

        let satValue = UInt64(self) / 1000
        if let formattedNumber = formatter.string(from: NSNumber(value: satValue)) {
            return formattedNumber
        } else {
            return ""
        }
    }
}
