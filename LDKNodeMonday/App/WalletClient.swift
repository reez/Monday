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
    public var appState = AppState.loading
    public var appError: Error?

    public init(keyClient: KeyClient) {
        self.keyClient = keyClient
        self.lightningClient = .live
    }

    func start() async {
        var backupInfo: BackupInfo?
        backupInfo = try? KeyClient.live.getBackupInfo()

        if backupInfo != nil {
            do {
                try await lightningClient.start()
                lightningClient.listenForEvents()
                await MainActor.run {
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

    func restart(newNetwork: Network, newServer: EsploraServer) async {
        do {
            await MainActor.run {
                self.appState = .loading
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

    func delete() async {  //TODO: Move logic to walletClient
        do {
            if lightningClient.status().isRunning {
                try lightningClient.stop()
            }
            try lightningClient.deleteDocuments()
            try lightningClient.deleteWallet()

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

public enum AppState {
    case onboarding
    case wallet
    case loading
    case error
}
