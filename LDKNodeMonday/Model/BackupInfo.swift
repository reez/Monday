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

    init(mnemonic: String, networkString: String, serverURL: String) {
        self.mnemonic = mnemonic
        self.networkString = networkString
        self.serverURL = serverURL
    }

    static func == (lhs: BackupInfo, rhs: BackupInfo) -> Bool {
        return lhs.mnemonic == rhs.mnemonic
    }
}

#if DEBUG
    let mockBackupInfo = BackupInfo(
        mnemonic: "",
        networkString: Network.signet.description,
        serverURL: EsploraServer.mutiny_signet.url
    )
#endif
