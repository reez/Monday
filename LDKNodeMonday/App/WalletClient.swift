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
    public var priceClient: PriceClient
    public var network = Network.signet
    public var server = EsploraServer.mutiny_signet
    public var balanceDetails: BalanceDetails = .empty
    public var transactions: [PaymentDetails] = []
    public var price: Double = 0.00
    public var appState = AppState.loading
    public var appError: Error?
    
    public var unifiedBalance: UInt64 {
        return balanceDetails.totalOnchainBalanceSats + balanceDetails.totalLightningBalanceSats
    }
    
    public var totalUSDValue: Double {
        let totalUSD = Double(unifiedBalance).valueInUSD(price: price)
        return totalUSD
    }

    public init(mode: AppMode) {
        switch mode {
        case .live:
            self.keyClient = .live
            self.lightningClient = .live
            self.priceClient = .live
        case .mock:
            self.keyClient = .mock
            self.lightningClient = .mock
            self.priceClient = .mock
        }
        Task {
            await updateBalances()
            updateTransactions()
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

    func updateTransactions() {
        self.transactions = lightningClient.listPayments()
    }
    
    func updateBalances() async {
        self.balanceDetails = await lightningClient.balanceDetails()
    }
    
    func updatePrice() async {
        do {
            let price = try await priceClient.fetchPrice()
            let copy = price  // To avoid issues with non-sendable object
            await MainActor.run {
                self.price = copy.usd
            }
        } catch let error {
            self.appError = error
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
