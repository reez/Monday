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
    public var lsp = LightningServiceProvider.see_signet
    public var appMode: AppMode
    public var appState = AppState.loading
    public var appError: Error?

    public init(appMode: AppMode) {
        self.appMode = appMode
        switch appMode {
        case .live:
            self.keyClient = .live
            self.lightningClient = .live
        case .mock:
            self.keyClient = .mock
            self.lightningClient = .mock
        }
    }

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
        backupInfo = try? self.keyClient.getBackupInfo()

        if backupInfo != nil {
            do {
                try await lightningClient.start()
                lightningClient.listenForEvents()
                await MainActor.run {
                    self.network = lightningClient.getNetwork()
                    self.server = lightningClient.getServer()

                    // Load LSP from keychain if available
                    if let savedLSPNodeId = try? self.keyClient.getLSP(),
                        !savedLSPNodeId.isEmpty,
                        let savedLSP = LightningServiceProvider.getByNodeId(savedLSPNodeId)
                    {
                        self.lsp = savedLSP
                    }

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

    func restart(
        newNetwork: Network,
        newServer: EsploraServer,
        appMode: AppMode? = .live,
        lsp: LightningServiceProvider? = nil
    ) async {
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

                if let lsp = lsp {
                    self.lsp = lsp
                }
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
