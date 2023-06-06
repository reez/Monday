//
//  Constants.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import Foundation
import SwiftUI

struct Constants {
    
    struct Config {

        struct EsploraServerURLNetwork {
            static let mainnet = "https://blockstream.info/api"
            static let regtest = "http://ldk-node.tnull.de:3002"
            static let signet = "https://mutinynet.com/api"
            static let testnet = "http://blockstream.info/testnet/api/"
        }
        
    }
    
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
                // ... and `Color.orange` just makes more sense to me
                return Color.orange
            case .testnet:
                return Color.red
            }
        }
    }
    
}
