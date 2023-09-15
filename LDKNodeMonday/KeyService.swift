//
//  KeyService.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 9/14/23.
//

import Foundation
import KeychainAccess
import LDKNode

private struct KeyService {
    private let keychain: Keychain

    init() {
        let keychain = Keychain(service: "com.matthewramsden.LDKNodeMonday.testservice")  // TODO: use `Bundle.main.displayName` or something like com.bdk.swiftwalletexample
            .label(Bundle.main.displayName)
            .synchronizable(true)
            .accessibility(.afterFirstUnlock)
        self.keychain = keychain
    }

    func saveBackupInfo(backupInfo: BackupInfo) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(backupInfo)
        keychain[data: "BackupInfo"] = data
    }

    func getBackupInfo() throws -> BackupInfo {
        guard let encryptedJsonData = try keychain.getData("BackupInfo") else {
            throw KeyServiceError.readError
        }
        let decoder = JSONDecoder()
        let backupInfo = try decoder.decode(BackupInfo.self, from: encryptedJsonData)
        return backupInfo
    }

    func deleteBackupInfo() throws {
        try keychain.remove("BackupInfo")
    }
}

struct KeyClient {
    let saveBackupInfo: (BackupInfo) throws -> Void
    let getBackupInfo: () throws -> BackupInfo
    let deleteBackupInfo: () throws -> Void

    private init(
        saveBackupInfo: @escaping (BackupInfo) throws -> Void,
        getBackupInfo: @escaping () throws -> BackupInfo,
        deleteBackupInfo: @escaping () throws -> Void
    ) {
        self.saveBackupInfo = saveBackupInfo
        self.getBackupInfo = getBackupInfo
        self.deleteBackupInfo = deleteBackupInfo
    }
}

extension KeyClient {
    static let live = Self(
        saveBackupInfo: { backupInfo in try KeyService().saveBackupInfo(backupInfo: backupInfo) },
        getBackupInfo: { try KeyService().getBackupInfo() },
        deleteBackupInfo: { try KeyService().deleteBackupInfo() }
    )
}

//#if DEBUG
//    extension KeyClient {
//        static let mock = Self(
//            saveBackupInfo: { _ in },
//            getBackupInfo: {
//                let mnemonicWords12 =
//                    "space echo position wrist orient erupt relief museum myself grain wisdom tumble"
//                let mnemonic = try Mnemonic.fromString(mnemonic: mnemonicWords12)
//                let secretKey = DescriptorSecretKey(
//                    network: mockKeyClientNetwork,
//                    mnemonic: mnemonic,
//                    password: nil
//                )
//                let descriptor = Descriptor.newBip86(
//                    secretKey: secretKey,
//                    keychain: .external,
//                    network: mockKeyClientNetwork
//                )
//                let changeDescriptor = Descriptor.newBip86(
//                    secretKey: secretKey,
//                    keychain: .internal,
//                    network: mockKeyClientNetwork
//                )
//                let backupInfo = BackupInfo(
//                    mnemonic: mnemonic.asString(),
//                    descriptor: descriptor.asString(),
//                    changeDescriptor: changeDescriptor.asStringPrivate()
//                )
//                return backupInfo
//            },
//            deleteBackupInfo: { try KeyService().deleteBackupInfo() }
//        )
//    }
//#endif
