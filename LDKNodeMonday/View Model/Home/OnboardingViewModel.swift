//
//  OnboardingViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 1/4/24.
//

import LDKNode
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Binding var appState: AppState
    let lightningClient: LightningNodeClient
    private let keyClient: KeyClient
    @Published var networkColor = Color.gray
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
                self.selectedEsploraServer =
                    availableServers(network: self.selectedNetwork).first!  // all networks have at least one server option
                try keyClient.saveNetwork(selectedNetwork.description)
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
                try keyClient.saveServerURL(selectedEsploraServer.url)
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

    init(
        appState: Binding<AppState>,
        lightningClient: LightningNodeClient,
        keyClient: KeyClient = .live
    ) {
        _appState = appState
        self.lightningClient = lightningClient
        self.keyClient = keyClient

        do {
            if let networkString = try keyClient.getNetwork() {
                self.selectedNetwork = Network(stringValue: networkString) ?? .signet
            }
            if let esploraURL = try keyClient.getServerURL() {
                self.selectedEsploraServer =
                    availableServers(network: self.selectedNetwork).first!
            }
        } catch {
            DispatchQueue.main.async {
                self.onboardingViewError = .init(
                    title: "Error Getting Network/Esplora",
                    detail: error.localizedDescription
                )
            }
        }
    }

    func saveSeed() {
        do {
            let backupInfo = BackupInfo(
                mnemonic: seedPhrase,
                networkString: selectedNetwork.description,
                serverURL: selectedEsploraServer.url
            )
            try keyClient.saveBackupInfo(backupInfo)
            DispatchQueue.main.async {
                self.appState = .wallet
            }
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.onboardingViewError = .init(
                    title: errorString.title,
                    detail: errorString.detail
                )
            }
        } catch {
            DispatchQueue.main.async {
                self.onboardingViewError = .init(
                    title: "Unexpected error",
                    detail: error.localizedDescription
                )
            }
        }
    }

    func getColor() {
        let color = lightningClient.getNetworkColor()
        DispatchQueue.main.async {
            self.networkColor = color
        }
    }

    private func updateSeedPhraseArray() {
        let trimmedWords = seedPhrase.trimmingCharacters(in: .whitespacesAndNewlines)
        seedPhraseArray = trimmedWords.split(separator: " ").map { String($0) }
    }
}
