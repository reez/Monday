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
    func saveNetwork(network: String) throws {
        keychain[string: "SelectedNetwork"] = network
    }

    func getNetwork() throws -> String? {
        return keychain[string: "SelectedNetwork"]
    }

    func deleteNetwork() throws {
        try keychain.remove("SelectedNetwork")
    }

    func saveEsploraURL(url: String) throws {
        keychain[string: "SelectedEsploraURL"] = url
    }

    func getEsploraURL() throws -> String? {
        return keychain[string: "SelectedEsploraURL"]
    }

    func deleteEsploraURL() throws {
        try keychain.remove("SelectedEsploraURL")
    }
}

struct KeyClient {
    let saveBackupInfo: (BackupInfo) throws -> Void
    let getBackupInfo: () throws -> BackupInfo
    let deleteBackupInfo: () throws -> Void

    let saveNetwork: (String) throws -> Void
    let getNetwork: () throws -> String?
    let saveEsploraURL: (String) throws -> Void
    let getEsploraURL: () throws -> String?
    let deleteNetwork: () throws -> Void
    let deleteEsplora: () throws -> Void

    private init(
        saveBackupInfo: @escaping (BackupInfo) throws -> Void,
        getBackupInfo: @escaping () throws -> BackupInfo,
        deleteBackupInfo: @escaping () throws -> Void,
        saveNetwork: @escaping (String) throws -> Void,
        getNetwork: @escaping () throws -> String?,
        saveEsploraURL: @escaping (String) throws -> Void,
        getEsploraURL: @escaping () throws -> String?,
        deleteNetwork: @escaping () throws -> Void,
        deleteEsplora: @escaping () throws -> Void
    ) {
        self.saveBackupInfo = saveBackupInfo
        self.getBackupInfo = getBackupInfo
        self.deleteBackupInfo = deleteBackupInfo
        self.saveNetwork = saveNetwork
        self.getNetwork = getNetwork
        self.saveEsploraURL = saveEsploraURL
        self.getEsploraURL = getEsploraURL
        self.deleteNetwork = deleteNetwork
        self.deleteEsplora = deleteEsplora
    }
}

extension KeyClient {
    static let live = Self(
        saveBackupInfo: { backupInfo in try KeyService().saveBackupInfo(backupInfo: backupInfo) },
        getBackupInfo: { try KeyService().getBackupInfo() },
        deleteBackupInfo: { try KeyService().deleteBackupInfo() },
        saveNetwork: { network in try KeyService().saveNetwork(network: network) },
        getNetwork: { try KeyService().getNetwork() },
        saveEsploraURL: { url in try KeyService().saveEsploraURL(url: url) },
        getEsploraURL: { try KeyService().getEsploraURL() },
        deleteNetwork: { try KeyService().deleteNetwork() },
        deleteEsplora: { try KeyService().deleteEsploraURL() }
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
            saveEsploraURL: { _ in },
            getEsploraURL: { nil },
            deleteNetwork: {},
            deleteEsplora: {}
        )
    }
#endif
