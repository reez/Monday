//
//  BitcoinNetworkColor.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import Foundation
import SwiftUI

enum BitcoinNetworkColor {
    case regtest
    case signet
    case mainnet
    case testnet
    
    var color: Color {
        switch self {
        case .regtest:
            return Color.green
        case .signet:
            return Color.yellow
        case .mainnet:
            // Supposed to be `Color.black`
            // ... but I'm just going to make it `Color.orange`
            // ... since `Color.black` might not work well for both light+dark mode
            return Color.orange
        case .testnet:
            return Color.red
        }
    }
}
