//
//  String+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 4/25/23.
//

import Foundation

extension String {
    
    func bolt11amount() -> String? {
        let regex = try! NSRegularExpression(pattern: "ln.*?(\\d+)", options: [])
        if let match = regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            let range = match.range(at: 1)
            if let swiftRange = Range(range, in: self) {
                let numberString = self[swiftRange]
                if let number = Int(numberString) {
                    let conversion = number * 100
                    return String(conversion)
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
           let formattedNumber = formatter.string(from: NSNumber(value: number)) {
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
