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
                static let allValues = [
                    EsploraServer.blockstream_bitcoin,
                    EsploraServer.mempoolspace_bitcoin,
                ]
            }
            struct Regtest {
                static let allValues = [
                    EsploraServer.local_regtest
                ]
            }
            struct Signet {
                static let allValues = [
                    EsploraServer.mutiny_signet,
                    EsploraServer.bdk_signet,
                    EsploraServer.lqwd_signet
                ]
            }
            struct Testnet {
                static let allValues = [
                    EsploraServer.blockstream_testnet,
                    EsploraServer.kuutamo_testnet,
                    EsploraServer.mempoolspace_testnet,
                ]
            }
        }

        struct LiquiditySourceLsps2 {
            struct Signet {
                static let mutiny = LSP.mutiny
                static let lqwd = LSP.lqwd2
            }
        }

        struct RGSServerURLNetwork {
            static let bitcoin = "https://rapidsync.lightningdevkit.org/snapshot/"
            static let testnet = "https://rapidsync.lightningdevkit.org/testnet/snapshot/"
            static let signet = "https://mutinynet.ltbl.io/snapshot"
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
        //        static let lqwd = LightningServiceProvider(
        //            address: "192.243.215.101:26010",
        //            nodeId: "035e8a9034a8c68f219aacadae748c7a3cd719109309db39b09886e5ff17696b1b",
        //            token: ""
        //        )
        static let lqwd2 = LightningServiceProvider(
            address: "192.243.215.101:27110",
            nodeId: "02764a0e09f2e8ec67708f11d853191e8ba4a7f06db1330fd0250ab3de10590a8e",
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

    static let blockstream_bitcoin = EsploraServer(
        name: "Blockstream",
        url: "https://blockstream.info/api"
    )
    static let mempoolspace_bitcoin = EsploraServer(
        name: "Mempool",
        url: "https://mempool.space/api"
    )

    static let mutiny_signet = EsploraServer(name: "Mutiny", url: "https://mutinynet.com/api")
    static let bdk_signet = EsploraServer(name: "BDK", url: "http://signet.bitcoindevkit.net")
    static let lqwd_signet = EsploraServer(name: "LQWD", url: "https://mutinynet.ltbl.io/api")

    static let local_regtest = EsploraServer(name: "Local", url: "http://127.0.0.1:3002")

    static let blockstream_testnet = EsploraServer(
        name: "Blockstream",
        url: "http://blockstream.info/testnet/api"
    )
    static let kuutamo_testnet = EsploraServer(
        name: "Kuutamo",
        url: "https://esplora.testnet.kuutamo.cloud"
    )
    static let mempoolspace_testnet = EsploraServer(
        name: "Mempool.space",
        url: "https://mempool.space/testnet/api"
    )
}
