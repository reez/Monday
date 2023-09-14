//
//  BackupInfo.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 9/14/23.
//

import Foundation

struct BackupInfo: Codable, Equatable {
    var mnemonic: String
    var descriptor: String
    var changeDescriptor: String

    init(mnemonic: String, descriptor: String, changeDescriptor: String) {
        self.mnemonic = mnemonic
        self.descriptor = descriptor
        self.changeDescriptor = changeDescriptor
    }

    static func == (lhs: BackupInfo, rhs: BackupInfo) -> Bool {
        return lhs.mnemonic == rhs.mnemonic && lhs.descriptor == rhs.descriptor
            && lhs.changeDescriptor == rhs.changeDescriptor
    }
}
