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
            struct Bitcoin {
                static let bitcoin_blockstream = "https://blockstream.info/api"
                static let bitcoin_mempoolspace = "https://mempool.space/api"
            }
            static let regtest = "http://ldk-node.tnull.de:3002"
            static let signet = "https://mutinynet.com/api"
            static let testnet = "http://blockstream.info/testnet/api/"
        }
        
        struct RGSServerURLNetwork {
            static let bitcoin = "https://rapidsync.lightningdevkit.org/snapshot/"
            static let testnet = "https://rapidsync.lightningdevkit.org/testnet/snapshot/"
        }
        
    }
    
    enum BitcoinNetworkColor {
        case bitcoin
        case regtest
        case signet
        case testnet
        
        var color: Color {
            switch self {
            case .regtest:
                return Color.green
            case .signet:
                return Color.yellow
            case .bitcoin:
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
