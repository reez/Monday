//
//  BackupInfo.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 9/14/23.
//

import Foundation
import LDKNode

struct BackupInfo: Codable, Equatable {
    var mnemonic: String
    var networkString: String
    var server: EsploraServer

    init(mnemonic: String, network: Network, server: EsploraServer) {
        self.mnemonic = mnemonic
        self.networkString = network.toString()
        self.server = server
    }

    static func == (lhs: BackupInfo, rhs: BackupInfo) -> Bool {
        return lhs.mnemonic == rhs.mnemonic
    }
}

#if DEBUG
let mockBackupInfo = BackupInfo(mnemonic: "", network: Network.signet, server: EsploraServer.mutiny_signet)
#endif

extension Network {
    /// Converts the enum case to a string representation
    func toString() -> String {
        switch self {
        case .bitcoin: return "bitcoin"
        case .testnet: return "testnet"
        case .signet: return "signet"
        case .regtest: return "regtest"
        }
    }
    
    /// Converts a string to the corresponding `Network` enum case
    static func fromString(_ string: String) -> Network? {
        switch string.lowercased() {
        case "bitcoin": return .bitcoin
        case "testnet": return .testnet
        case "signet": return .signet
        case "regtest": return .regtest
        default: return nil // Handle invalid string input
        }
    }
}
