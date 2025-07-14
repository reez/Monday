//
//  LightningServiceProvider.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/24/24.
//

import Foundation

public struct LightningServiceProvider: Hashable {
    let name: String
    let address: String
    let nodeId: String
    let token: String

    static let see_signet = LightningServiceProvider(
        name: "See",
        address: "3.84.56.108:39735",
        nodeId: "0371d6fd7d75de2d0372d03ea00e8bacdacb50c27d0eaea0a76a0622eff1f5ef2b",
        token: "4GH1W3YW"
    )
    /// [Olympus Docs](https://docs.zeusln.app/lsp/api/flow/)
    static let olympus_mainnet = LightningServiceProvider(
        name: "Olympus",
        address: "45.79.192.236:9735",
        nodeId: "031b301307574bbe9b9ac7b79cbe1700e31e544513eae0b5d7497483083f99e581",
        token: ""
    )
    static let olympus_testnet = LightningServiceProvider(
        name: "Olympus",
        address: "139.144.22.237:9735",
        nodeId: "03e84a109cd70e57864274932fc87c5e6434c59ebb8e6e7d28532219ba38f7f6df",
        token: ""
    )
    static let olympus_signet = LightningServiceProvider(
        name: "Olympus",
        address: "45.79.201.241:9735",
        nodeId: "032ae843e4d7d177f151d021ac8044b0636ec72b1ce3ffcde5c04748db2517ab03",
        token: ""
    )
    static let lqwd_signet = LightningServiceProvider(
        name: "Lqwd",
        address: "192.243.215.98:27100",
        nodeId: "0275eb44504d53b2a083852e3bffcc4e178195b9546c162590d8c282f3ed3243fc",
        token: ""
    )
    static let megalith_signet = LightningServiceProvider(
        name: "Megalith",
        address: "143.198.63.18:9735",
        nodeId: "02d71bd10286058cfb8c983f761c069a549d822ca3eb4a4c67d15aa8bec7483251",
        token: ""
    )

    static func getByNodeId(_ nodeId: String) -> LightningServiceProvider? {
        let allProviders: [LightningServiceProvider] = [
            .see_signet,
            .olympus_mainnet,
            .olympus_testnet,
            .olympus_signet,
            .lqwd_signet,
            .megalith_signet,
        ]

        return allProviders.first { $0.nodeId == nodeId }
    }
}
