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
    func saveNetwork(network: Network) throws {
        let currentBackupInfo = try self.getBackupInfo()
        let newBackupInfo = BackupInfo(mnemonic: currentBackupInfo.mnemonic, network: network, server: currentBackupInfo.server)
        try saveBackupInfo(backupInfo: newBackupInfo)
    }

    func getNetwork() throws -> String? {
        let currentBackupInfo = try self.getBackupInfo()
        return currentBackupInfo.networkString
    }

    func saveServer(server: EsploraServer) throws {
        let currentBackupInfo = try self.getBackupInfo()
        let newBackupInfo = BackupInfo(mnemonic: currentBackupInfo.mnemonic, network: Network.fromString(currentBackupInfo.networkString)!, server: server)
        try saveBackupInfo(backupInfo: newBackupInfo)
    }

    func getEsploraURL() throws -> String? {
        let currentBackupInfo = try self.getBackupInfo()
        return currentBackupInfo.server.url
    }
}

struct KeyClient {
    let saveBackupInfo: (BackupInfo) throws -> Void
    let getBackupInfo: () throws -> BackupInfo
    let deleteBackupInfo: () throws -> Void

    let saveNetwork: (Network) throws -> Void
    let getNetwork: () throws -> String?
    let saveServer: (EsploraServer) throws -> Void
    let getEsploraURL: () throws -> String?

    private init(
        saveBackupInfo: @escaping (BackupInfo) throws -> Void,
        getBackupInfo: @escaping () throws -> BackupInfo,
        deleteBackupInfo: @escaping () throws -> Void,
        saveNetwork: @escaping (Network) throws -> Void,
        getNetwork: @escaping () throws -> String?,
        saveServer: @escaping (EsploraServer) throws -> Void,
        getEsploraURL: @escaping () throws -> String?
    ) {
        self.saveBackupInfo = saveBackupInfo
        self.getBackupInfo = getBackupInfo
        self.deleteBackupInfo = deleteBackupInfo
        self.saveNetwork = saveNetwork
        self.getNetwork = getNetwork
        self.saveServer = saveServer
        self.getEsploraURL = getEsploraURL
    }
}

extension KeyClient {
    static let live = Self(
        saveBackupInfo: { backupInfo in try KeyService().saveBackupInfo(backupInfo: backupInfo) },
        getBackupInfo: { try KeyService().getBackupInfo() },
        deleteBackupInfo: { try KeyService().deleteBackupInfo() },
        saveNetwork: { network in try KeyService().saveNetwork(network: network) },
        getNetwork: { try KeyService().getNetwork() },
        saveServer: { server in try KeyService().saveServer(server: server) },
        getEsploraURL: { try KeyService().getEsploraURL() }
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
            saveServer: { _ in },
            getEsploraURL: { nil }
        )
    }
#endif
