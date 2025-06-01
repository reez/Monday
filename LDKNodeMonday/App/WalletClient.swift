//
//  WalletClient.swift
//  LDKNodeMonday
//
//  Created by Daniel Nordh on 23/01/2025.
//

import Foundation
import LDKNode
import SwiftUI

@Observable
public class WalletClient {

    public var keyClient: KeyClient
    public var lightningClient: LightningNodeClient
    public var network = Network.signet
    public var server = EsploraServer.mutiny_signet
    public var appMode: AppMode
    public var appState = AppState.loading
    public var appError: Error?

    private init(appMode: AppMode, keyClient: KeyClient, lightningClient: LightningNodeClient) {
        self.appMode = appMode
        self.keyClient = keyClient
        self.lightningClient = lightningClient
    }

    public static func create(appMode: AppMode) async throws -> WalletClient {
        switch appMode {
        case .live:
            try await LightningNodeService.initializeShared()
            return WalletClient(appMode: .live, keyClient: .live, lightningClient: .live)
        case .mock:
            return WalletClient(appMode: .mock, keyClient: .mock, lightningClient: .mock)
        }
    }

    public static let mock = WalletClient(appMode: .mock, keyClient: .mock, lightningClient: .mock)

    func createWallet(seedPhrase: String, network: Network, server: EsploraServer) async {
        do {
            let backupInfo = BackupInfo(
                mnemonic: seedPhrase == "" ? generateEntropyMnemonic() : seedPhrase,
                networkString: network.description,
                serverURL: server.url
            )
            try keyClient.saveBackupInfo(backupInfo)
            await self.start()
        } catch let error {
            await MainActor.run {
                self.appError = error
                self.appState = .error
            }
        }
    }

    func start() async {
        var backupInfo: BackupInfo?
        backupInfo = try? KeyClient.live.getBackupInfo()

        if backupInfo != nil {
            do {
                try await lightningClient.start()
                lightningClient.listenForEvents()
                await MainActor.run {
                    self.network = lightningClient.getNetwork()
                    self.server = lightningClient.getServer()
                    self.appState = .wallet
                }
            } catch let error {
                await MainActor.run {
                    self.appError = error
                    self.appState = .error
                }
            }
        } else {
            await MainActor.run {
                self.appState = .onboarding
            }
        }
    }

    func stop() {
        try? self.lightningClient.stop()
    }

    func restart(newNetwork: Network, newServer: EsploraServer, appMode: AppMode? = .live) async {
        do {
            await MainActor.run {
                self.appState = .loading
                switch appMode {
                case .mock:
                    self.appMode = .mock
                    self.keyClient = .mock
                    self.lightningClient = .mock
                default:
                    self.appMode = .live
                    self.keyClient = .live
                    self.lightningClient = .live
                }
            }
            try await lightningClient.restart()
            lightningClient.listenForEvents()
            await MainActor.run {
                self.network = newNetwork
                self.server = newServer
                self.appState = .wallet
            }
        } catch let error {
            debugPrint(error)
            await MainActor.run {
                self.appError = error
                self.appState = .error
            }
        }
    }

    func delete() async {
        do {
            if lightningClient.status().isRunning {
                try lightningClient.stop()
            }
            try lightningClient.deleteDocuments()
            try lightningClient.deleteWallet()
            try lightningClient.reset()

            await MainActor.run {
                self.appState = .onboarding
            }
        } catch let error {
            await MainActor.run {
                self.appError = error
                self.appState = .error
            }
        }
    }
}

public enum AppMode {
    case live
    case mock
}

public enum AppState {
    case onboarding
    case wallet
    case loading
    case error
}
