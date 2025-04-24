//
//  Constants.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import Foundation
import LDKNode
import SwiftUI

struct Constants {

    static let satsPerBtc: UInt64 = 1_00_000_000
    static let msatsPerSat: UInt64 = 1_000

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
                    EsploraServer.lqwd_signet,
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
                static let see = LSP.see
                static let lqwd = LSP.lqwd
                static let olympus = LSP.olympus
            }
        }

        struct RGSServerURLNetwork {
            static let bitcoin = "https://rapidsync.lightningdevkit.org/snapshot/"
            static let testnet = "https://rapidsync.lightningdevkit.org/testnet/snapshot/"
            static let signet = "https://rgs.mutinynet.com/snapshot"
        }

    }

    struct LSP {
        static let see = LightningServiceProvider(
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
        static let lqwd = LightningServiceProvider(
            address: "192.243.215.98:27100",
            nodeId: "0275eb44504d53b2a083852e3bffcc4e178195b9546c162590d8c282f3ed3243fc",
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

public struct EsploraServer: Hashable {
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

extension EsploraServer {
    private static let urlToServer: [String: EsploraServer] = [
        blockstream_bitcoin.url: .blockstream_bitcoin,
        mempoolspace_bitcoin.url: .mempoolspace_bitcoin,
        mutiny_signet.url: .mutiny_signet,
        bdk_signet.url: .bdk_signet,
        lqwd_signet.url: .lqwd_signet,
        local_regtest.url: .local_regtest,
        blockstream_testnet.url: .blockstream_testnet,
        kuutamo_testnet.url: .kuutamo_testnet,
        mempoolspace_testnet.url: .mempoolspace_testnet,
    ]

    init?(URLString: String) {
        switch URLString {
        case "https://blockstream.info/api": self = .blockstream_bitcoin
        case "https://mempool.space/api": self = .mempoolspace_bitcoin
        case "https://mutinynet.com/api": self = .mutiny_signet
        case "http://signet.bitcoindevkit.net": self = .bdk_signet
        case "https://mutinynet.ltbl.io/api": self = .lqwd_signet
        case "http://127.0.0.1:3002": self = .local_regtest
        case "http://blockstream.info/testnet/api": self = .blockstream_testnet
        case "https://esplora.testnet.kuutamo.cloud": self = .kuutamo_testnet
        case "https://mempool.space/testnet/api": self = .mempoolspace_testnet
        default: return nil
        }
    }
}

public func availableServers(network: Network) -> [EsploraServer] {
    switch network {
    case .bitcoin:
        return Constants.Config.EsploraServerURLNetwork.Bitcoin.allValues
    case .testnet:
        return Constants.Config.EsploraServerURLNetwork.Testnet.allValues
    case .regtest:
        return Constants.Config.EsploraServerURLNetwork.Regtest.allValues
    case .signet:
        return Constants.Config.EsploraServerURLNetwork.Signet.allValues
    }
}
