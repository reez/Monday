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

    init(mnemonic: String, networkString: String) {
        self.mnemonic = mnemonic
        self.networkString = networkString
    }

    static func == (lhs: BackupInfo, rhs: BackupInfo) -> Bool {
        return lhs.mnemonic == rhs.mnemonic
    }
}

#if DEBUG
let mockBackupInfo = BackupInfo(mnemonic: "", networkString: Network.signet.description)
#endif
