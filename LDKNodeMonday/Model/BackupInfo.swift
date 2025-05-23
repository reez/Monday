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
    var serverURL: String
    var lspNodeId: String?

    init(mnemonic: String, networkString: String, serverURL: String, lspString: String? = nil) {
        self.mnemonic = mnemonic
        self.networkString = networkString
        self.serverURL = serverURL
        self.lspNodeId = lspString
    }

    static func == (lhs: BackupInfo, rhs: BackupInfo) -> Bool {
        return lhs.mnemonic == rhs.mnemonic &&
               lhs.networkString == rhs.networkString &&
               lhs.serverURL == rhs.serverURL &&
               lhs.lspNodeId == rhs.lspNodeId
    }
}


//#if DEBUG
let mockBackupInfo = BackupInfo(
    mnemonic: "",
    networkString: Network.signet.description,
    serverURL: EsploraServer.mutiny_signet.url
)
//#endif
