//
//  Date+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 4/25/23.
//

import Foundation

extension Date {
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d 'at' h:mm a"
        let dateString = formatter.string(from: self)
        return dateString
    }
}
