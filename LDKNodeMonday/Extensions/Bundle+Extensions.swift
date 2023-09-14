//
//  Bundle+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 9/14/23.
//

import Foundation

extension Bundle {
    var displayName: String {
        return Bundle.main.infoDictionary?["CFBundleName"] as? String ?? Bundle.main
            .bundleIdentifier ?? "Unknown Bundle"
    }
}
