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
                let networkString = selectedNetwork.description
                try KeyClient.live.saveNetwork(networkString)
                self.selectedEsploraServer =
                    availableEsploraServers.first ?? EsploraServer(name: "", url: "")
                try KeyClient.live.saveEsploraURL(selectedEsploraServer.url)
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
                try KeyClient.live.saveEsploraURL(selectedEsploraServer.url)
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
    var availableEsploraServers: [EsploraServer] {
        switch selectedNetwork {
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

    init(appState: Binding<AppState>) {
        _appState = appState

        do {
            if let networkString = try KeyClient.live.getNetwork() {
                self.selectedNetwork = Network(stringValue: networkString) ?? .signet
            }
            if let esploraURL = try KeyClient.live.getEsploraURL() {
                self.selectedEsploraServer =
                    availableEsploraServers.first(where: {
                        $0.url == esploraURL
                    }) ?? EsploraServer.mutiny_signet
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
            let backupInfo = BackupInfo(mnemonic: seedPhrase)
            try KeyClient.live.saveBackupInfo(backupInfo)
            try KeyClient.live.saveNetwork(selectedNetwork.description)
            try KeyClient.live.saveEsploraURL(selectedEsploraServer.url)
            LightningNodeService.shared = LightningNodeService()
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
        let color = LightningNodeService.shared.networkColor
        DispatchQueue.main.async {
            self.networkColor = color
        }
    }

    private func updateSeedPhraseArray() {
        let trimmedWords = seedPhrase.trimmingCharacters(in: .whitespacesAndNewlines)
        seedPhraseArray = trimmedWords.split(separator: " ").map { String($0) }
    }
}
