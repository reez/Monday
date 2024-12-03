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
                static let blockstream = EsploraServer(name: "Blockstream", url: "https://blockstream.info/api")
                static let mempoolspace = EsploraServer(name: "Mempool.space", url: "https://mempool.space/api")
                static let allValues = [
                    blockstream,
                    mempoolspace,
                ]
            }
            struct Regtest {
                static let local = EsploraServer(name: "Local", url: "http://127.0.0.1:3002")
                static let allValues = [
                    local
                ]
            }
            struct Signet {
                static let bdk = EsploraServer(name: "BDK", url: "http://signet.bitcoindevkit.net")
                static let mutiny = EsploraServer(name: "Mutiny", url: "https://mutinynet.com/api")
                static let allValues = [
                    mutiny,
                    bdk,
                ]
            }
            struct Testnet {
                static let blockstream = EsploraServer(name: "Blockstream", url: "http://blockstream.info/testnet/api")
                static let kuutamo = EsploraServer(name: "Kuutamo", url: "https://esplora.testnet.kuutamo.cloud")
                static let mempoolspace = EsploraServer(name: "Mempool.space", url: "https://mempool.space/testnet/api")
                static let allValues = [
                    blockstream,
                    kuutamo,
                    mempoolspace,
                ]
            }
        }

        struct LiquiditySourceLsps2 {
            struct Signet {
                static let mutiny = LSP.mutiny
            }
        }

        struct RGSServerURLNetwork {
            static let bitcoin = "https://rapidsync.lightningdevkit.org/snapshot/"
            static let testnet = "https://rapidsync.lightningdevkit.org/testnet/snapshot/"
        }

    }

    struct LSP {
        static let mutiny = LightningServiceProvider(
            address: "3.84.56.108:39735",
            nodeId: "0371d6fd7d75de2d0372d03ea00e8bacdacb50c27d0eaea0a76a0622eff1f5ef2b",
            token: "4GH1W3YW"
        )
        /// [Olympus Docs](https://docs.zeusln.app/lsp/api/flow/)
        static let olympus = LightningServiceProvider(
            address: "45.79.192.236:9735",
            nodeId: "031b301307574bbe9b9ac7b79cbe1700e31e544513eae0b5d7497483083f99e581",
            token: ""
        )
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

struct EsploraServer: Hashable {
    var name: String
    var url: String
}
