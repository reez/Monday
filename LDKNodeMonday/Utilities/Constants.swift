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
        static let listeningAddress = "0.0.0.0:9735"
        static let DefaultCltvExpiryDelta = UInt32(2048)
        
        struct EsploraServerURLNetwork {
            static let regtest = "http://ldk-node.tnull.de:3002"
            static let signet = "https://mutinynet.com/api"
            static let testnet = "http://blockstream.info/testnet/api/"
        }
        
        struct ChosenNetwork {
            static let regtest = "regtest"
            static let signet = "signet"
            static let testnet = "testnet"
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
                return Color.orange
            case .testnet:
                return Color.red
            }
        }
    }
    
}

//struct Constants {
//    static let listeningAddress = "0.0.0.0:9735"
//    static let DefaultCltvExpiryDelta = UInt32(2048)
//}
//
//struct EsploraServerURLNetwork {
//    static let regtest = "http://ldk-node.tnull.de:3002"
//    static let signet = "https://mutinynet.com/api"
//    static let testnet = "http://blockstream.info/testnet/api/"
//}
//
//struct ChosenNetwork {
//    static let regtest = "regtest"
//    static let signet = "signet"
//    static let testnet = "testnet"
//}

//struct NetworkInfo {
//    static let regtest = NetworkConfiguration(
//        chosenNetwork: ChosenNetwork.regtest,
//        esploraServerUrl: EsploraServerURLNetwork.regtest,
//        listeningAddress: Constants.listeningAddress,
//        networkColor: BitcoinNetworkColor.regtest.color
//    )
//
//    static let signet = NetworkConfiguration(
//        chosenNetwork: ChosenNetwork.signet,
//        esploraServerUrl: EsploraServerURLNetwork.signet,
//        listeningAddress: Constants.listeningAddress,
//        networkColor: BitcoinNetworkColor.signet.color
//    )
//
//    static let testnet = NetworkConfiguration(
//        chosenNetwork: ChosenNetwork.testnet,
//        esploraServerUrl: EsploraServerURLNetwork.testnet,
//        listeningAddress: Constants.listeningAddress,
//        networkColor: BitcoinNetworkColor.testnet.color
//    )
//}

//struct NetworkConfiguration {
//    let chosenNetwork: String
//    let esploraServerUrl: String
//    let listeningAddress: String
//    let networkColor: Color
//}
