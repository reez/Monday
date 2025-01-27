//
//  OnboardingViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 1/4/24.
//

import LDKNode
import SwiftUI

class OnboardingViewModel: ObservableObject {
    let lightningClient: LightningNodeClient
    let networkSettingsViewModel: NetworkSettingsViewModel
    @Binding var walletClient: WalletClient
    @Published var onboardingViewError: MondayError?
    @Published var seedPhrase: String = "" {
        didSet {
            updateSeedPhraseArray()
        }
    }
    @Published var seedPhraseArray: [String] = []
    @Published var selectedNetwork: Network = .signet {
        didSet {
            do {
                guard let server = availableServers(network: walletClient.network).first else {
                    // This should never happen, but if it does:
                    fatalError(
                        "Configuration error: No Esplora servers available for \(selectedNetwork)"
                    )
                }
                self.selectedEsploraServer = server
                try walletClient.keyClient.saveNetwork(selectedNetwork.description)
            } catch {
                DispatchQueue.main.async {
                    self.onboardingViewError = .init(
                        title: "Error Selecting Network",
                        detail: error.localizedDescription
                    )
                }
            }
        }
    }
    @Published var selectedEsploraServer: EsploraServer = EsploraServer.mutiny_signet
    {
        didSet {
            do {
                try walletClient.keyClient.saveServerURL(selectedEsploraServer.url)
            } catch {
                DispatchQueue.main.async {
                    self.onboardingViewError = .init(
                        title: "Error Selecting Esplora",
                        detail: error.localizedDescription
                    )
                }
            }
        }
    }

    var buttonColor: Color {
        switch selectedNetwork {
        case .bitcoin:
            return Constants.BitcoinNetworkColor.bitcoin.color
        case .testnet:
            return Constants.BitcoinNetworkColor.testnet.color
        case .signet:
            return Constants.BitcoinNetworkColor.signet.color
        case .regtest:
            return Constants.BitcoinNetworkColor.regtest.color
        }
    }

    init(walletClient: Binding<WalletClient>, networkSettingsViewModel: NetworkSettingsViewModel) {
        _walletClient = walletClient
        self.networkSettingsViewModel = networkSettingsViewModel
        self.lightningClient = walletClient.lightningClient.wrappedValue
        self.selectedNetwork = walletClient.network.wrappedValue
        self.selectedEsploraServer = walletClient.server.wrappedValue
    }

    func saveSeed() async {
        await walletClient.createWallet(
            seedPhrase: seedPhrase,
            network: selectedNetwork,
            server: selectedEsploraServer
        )
    }

    private func updateSeedPhraseArray() {
        let trimmedWords = seedPhrase.trimmingCharacters(in: .whitespacesAndNewlines)
        seedPhraseArray = trimmedWords.split(separator: " ").map { String($0) }
    }
}
