//
//  URL+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 8/25/24.
//

import Foundation

extension URL {
    func queryParameters() -> [String: String] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems
        else {
            return [:]
        }

        return Dictionary(
            uniqueKeysWithValues: queryItems.compactMap { item in
                guard let value = item.value else { return nil }
                return (item.name, value)
            }
        )
    }
}
