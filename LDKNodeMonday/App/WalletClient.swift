//
//  WalletClient.swift
//  LDKNodeMonday
//
//  Created by Daniel Nordh on 20/12/2024.
//

import Foundation
import LDKNode
import SwiftUI

@Observable
public class WalletClient {

    public var network = Network.signet
    public var server = EsploraServer.mutiny_signet
    public var appState = AppState.loading
    public var appError: Error?

    private var keyClient: KeyClient
    private var backupInfo: BackupInfo?

    public init(keyClient: KeyClient) {
        self.keyClient = keyClient
    }

    public func start() async {
        do {
            backupInfo = try KeyClient.live.getBackupInfo()
        } catch let error {
            debugPrint(error)  // TODO: Show error on relevant screen, unless this is thrown if no seed has been saved
            self.appError = error
        }

        if backupInfo == nil {
            self.appState = .onboarding
        } else {
            do {
                try await LightningNodeService.shared.start()
                LightningNodeService.shared.listenForEvents()
                await MainActor.run {
                    self.appState = .wallet
                    self.network = LightningNodeService.shared.network
                }
            } catch let error {
                debugPrint(error)  // TODO: Show error on relevant screen
                self.appError = error
            }
        }
    }

    public func restart(newNetwork: Network?, newServer: EsploraServer?) async {
        do {
            let newNetwork = newNetwork != nil ? newNetwork! : self.network
            let newServer =
                newServer != nil
                ? newServer! : availableEsploraServers().first ?? EsploraServer(name: "", url: "")
            try KeyClient.live.saveNetwork(newNetwork.description)
            try KeyClient.live.saveEsploraURL(newServer.url)

            await MainActor.run {
                self.network = newNetwork
                self.server = newServer
            }

            do {
                self.appState = .loading
                try? LightningNodeService.shared.stop()
                LightningNodeService.reset()
                try await LightningNodeService.shared.start()
                LightningNodeService.shared.listenForEvents()
                await MainActor.run {
                    self.appState = .wallet
                }
            } catch let error {
                debugPrint(error)  // TODO: Show error on relevant screen
                self.appError = error
            }
        } catch {
            /*
            DispatchQueue.main.async {
                self.onboardingViewError = .init(
                    title: "Error Selecting Network",
                    detail: error.localizedDescription
                )
            }
            */
        }
    }

    public func availableEsploraServers() -> [EsploraServer] {
        switch network {
        case .bitcoin:
            return Constants.Config.EsploraServerURLNetwork.Bitcoin.allValues
        case .testnet:
            return Constants.Config.EsploraServerURLNetwork.Testnet.allValues
        case .regtest:
            return Constants.Config.EsploraServerURLNetwork.Regtest.allValues
        case .signet:
            return Constants.Config.EsploraServerURLNetwork.Signet.allValues
        }
    }
}

public enum AppState {
    case onboarding
    case wallet
    case loading
    case error  // Currently unused in App()
}
