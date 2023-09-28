//
//  BackupInfo.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 9/14/23.
//

import Foundation

struct BackupInfo: Codable, Equatable {
    var mnemonic: String
    init(mnemonic: String) {
        self.mnemonic = mnemonic
    }

    static func == (lhs: BackupInfo, rhs: BackupInfo) -> Bool {
        return lhs.mnemonic == rhs.mnemonic
    }
}

#if DEBUG
let mockBackupInfo = BackupInfo(mnemonic: "")
#endif
