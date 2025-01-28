//
//  OnboardingViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 1/4/24.
//

import Combine
import LDKNode
import SwiftUI

class OnboardingViewModel: ObservableObject {
    let lightningClient: LightningNodeClient
    @Published var networkSettingsViewModel: NetworkSettingsViewModel
    @Binding var walletClient: WalletClient
    @Published var onboardingViewError: MondayError?
    @Published var seedPhrase: String = "" {
        didSet {
            updateSeedPhraseArray()
        }
    }
    @Published var seedPhraseArray: [String] = []
    private var cancellables = Set<AnyCancellable>()

    init(walletClient: Binding<WalletClient>, networkSettingsViewModel: NetworkSettingsViewModel) {
        _walletClient = walletClient
        self.networkSettingsViewModel = networkSettingsViewModel
        self.lightningClient = walletClient.lightningClient.wrappedValue

        networkSettingsViewModel.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }

    func saveSeed() async {
        await walletClient.createWallet(
            seedPhrase: seedPhrase,
            network: networkSettingsViewModel.selectedNetwork,
            server: networkSettingsViewModel.selectedEsploraServer
        )
    }

    private func updateSeedPhraseArray() {
        let trimmedWords = seedPhrase.trimmingCharacters(in: .whitespacesAndNewlines)
        seedPhraseArray = trimmedWords.split(separator: " ").map { String($0) }
    }
}
