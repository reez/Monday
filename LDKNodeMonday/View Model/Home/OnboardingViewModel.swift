//
//  OnboardingViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 1/4/24.
//

import LDKNode
import SwiftUI

@Observable
class OnboardingViewModel  {
    var networkColor = Color.gray
    var onboardingViewError: MondayError?
    var seedPhrase: String = "" {
        didSet {
            updateSeedPhraseArray()
        }
    }
    var seedPhraseArray: [String] = []
    var selectedNetwork: Network = .signet {
        didSet {
            do {
                let networkString = selectedNetwork.description
                try KeyClient.live.saveNetwork(networkString)
                self.selectedEsploraServer = availableEsploraServers.first!
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
    var selectedEsploraServer: EsploraServer = Constants.Config.EsploraServerURLNetwork.Signet.mutiny {
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

    init() {

        do {
            if let networkString = try KeyClient.live.getNetwork() {
                self.selectedNetwork = Network(stringValue: networkString) ?? .signet
            } else {
                self.selectedNetwork = .signet
            }
            if let esploraURL = try KeyClient.live.getEsploraURL() {
                self.selectedEsploraServer = availableEsploraServers.first(where: { $0.url == esploraURL })!
            } else {
                self.selectedEsploraServer = availableEsploraServers.first!
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
                UserDefaults.standard.set(false, forKey: "isOnboarding")
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
