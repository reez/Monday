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
        let keychain = Keychain(service: "com.matthewramsden.LDKNodeMonday.testservice")
            .label(Bundle.main.displayName)
            .synchronizable(false)
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

extension KeyService {
    func saveNetwork(networkString: String) throws {
        let currentBackupInfo = try self.getBackupInfo()
        let newBackupInfo = BackupInfo(
            mnemonic: currentBackupInfo.mnemonic,
            networkString: networkString,
            serverURL: currentBackupInfo.serverURL
        )
        try self.saveBackupInfo(backupInfo: newBackupInfo)
    }

    func getNetwork() throws -> String? {
        let backupInfo = try self.getBackupInfo()
        return backupInfo.networkString
    }

    func saveServerURL(url: String) throws {
        let currentBackupInfo = try self.getBackupInfo()
        let newBackupInfo = BackupInfo(
            mnemonic: currentBackupInfo.mnemonic,
            networkString: currentBackupInfo.networkString,
            serverURL: url
        )
        try self.saveBackupInfo(backupInfo: newBackupInfo)
    }

    func getServerURL() throws -> String? {
        let backupInfo = try self.getBackupInfo()
        return backupInfo.serverURL
    }
}

struct KeyClient {
    let saveBackupInfo: (BackupInfo) throws -> Void
    let getBackupInfo: () throws -> BackupInfo
    let deleteBackupInfo: () throws -> Void

    let saveNetwork: (String) throws -> Void
    let getNetwork: () throws -> String?
    let saveServerURL: (String) throws -> Void
    let getServerURL: () throws -> String?

    private init(
        saveBackupInfo: @escaping (BackupInfo) throws -> Void,
        getBackupInfo: @escaping () throws -> BackupInfo,
        deleteBackupInfo: @escaping () throws -> Void,
        saveNetwork: @escaping (String) throws -> Void,
        getNetwork: @escaping () throws -> String?,
        saveServerURL: @escaping (String) throws -> Void,
        getServerURL: @escaping () throws -> String?
    ) {
        self.saveBackupInfo = saveBackupInfo
        self.getBackupInfo = getBackupInfo
        self.deleteBackupInfo = deleteBackupInfo
        self.saveNetwork = saveNetwork
        self.getNetwork = getNetwork
        self.saveServerURL = saveServerURL
        self.getServerURL = getServerURL
    }
}

extension KeyClient {
    static let live = Self(
        saveBackupInfo: { backupInfo in try KeyService().saveBackupInfo(backupInfo: backupInfo) },
        getBackupInfo: { try KeyService().getBackupInfo() },
        deleteBackupInfo: { try KeyService().deleteBackupInfo() },
        saveNetwork: { network in try KeyService().saveNetwork(networkString: network) },
        getNetwork: { try KeyService().getNetwork() },
        saveServerURL: { url in try KeyService().saveServerURL(url: url) },
        getServerURL: { try KeyService().getServerURL() }
    )
}

#if DEBUG
    extension KeyClient {
        static let mock = Self(
            saveBackupInfo: { _ in },
            getBackupInfo: { mockBackupInfo },
            deleteBackupInfo: {},
            saveNetwork: { _ in },
            getNetwork: { nil },
            saveServerURL: { _ in },
            getServerURL: { nil }
        )
    }
#endif
