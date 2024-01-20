//
//  Network+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 1/6/24.
//

import Foundation
import LDKNode

extension Network {
    var description: String {
        switch self {
        case .bitcoin: return "bitcoin"
        case .testnet: return "testnet"
        case .signet: return "signet"
        case .regtest: return "regtest"
        }
    }

    init?(stringValue: String) {
        switch stringValue {
        case "bitcoin": self = .bitcoin
        case "testnet": self = .testnet
        case "signet": self = .signet
        case "regtest": self = .regtest
        default: return nil
        }
    }
}
