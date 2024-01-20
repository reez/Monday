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
                static let bitcoin_kuutamo = "https://esplora.kuutamo.cloud"
                static let bitcoin_mempoolspace = "https://mempool.space/api"
                static let allValues = [bitcoin_blockstream, bitcoin_kuutamo, bitcoin_mempoolspace]
            }
            static let regtest = "http://127.0.0.1:3002"
            static let signet = "https://mutinynet.com/api"
            struct Testnet {
                static let testnet_blockstream = "http://blockstream.info/testnet/api"
                static let testnet_kuutamo = "https://esplora.testnet.kuutamo.cloud"
                static let testnet_mempoolspace = "https://mempool.space/testnet/api"
                static let allValues = [testnet_blockstream, testnet_kuutamo, testnet_mempoolspace]
            }
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
