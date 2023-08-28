//
//  String+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 4/25/23.
//

import Foundation

extension String {

    func bolt11amount() -> String? {
        let regex = try! NSRegularExpression(pattern: "ln.*?(\\d+)([munp]?)", options: [])
        if let match = regex.firstMatch(
            in: self,
            options: [],
            range: NSRange(location: 0, length: self.utf16.count)
        ) {
            let amountRange = match.range(at: 1)
            let multiplierRange = match.range(at: 2)

            if let amountSwiftRange = Range(amountRange, in: self),
                let multiplierSwiftRange = Range(multiplierRange, in: self)
            {

                let amountString = self[amountSwiftRange]
                let multiplierString = self[multiplierSwiftRange]
                let numberFormatter = NumberFormatter()

                if let amount = numberFormatter.number(from: String(amountString))?.doubleValue {
                    var conversion = amount

                    switch multiplierString {
                    case "m":
                        conversion *= 0.001
                    case "u":
                        conversion *= 0.000001
                    case "n":
                        conversion *= 0.000000001
                    case "p":
                        conversion *= 0.000000000001
                    default:
                        break
                    }

                    let convertedAmount = conversion * 100_000_000
                    let formattedAmount = String(format: "%.0f", convertedAmount)
                    return formattedAmount
                }
            }
        }

        return nil
    }

    func formattedAmount() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSize = 3

        if let number = Int(self),
            let formattedNumber = formatter.string(from: NSNumber(value: number))
        {
            return formattedNumber
        } else {
            return ""
        }
    }

    func parseConnectionInfo() -> Peer? {
        if let atIndex = self.firstIndex(of: "@") {
            let nodeID = String(self[..<atIndex])
            let address = String(self[self.index(after: atIndex)...])
            return Peer(nodeID: nodeID, address: address)
        } else {
            return nil
        }
    }

}
