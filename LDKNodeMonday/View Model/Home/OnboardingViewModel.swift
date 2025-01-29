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
    @Binding var walletClient: WalletClient
    @Published var onboardingViewError: MondayError?
    @Published var seedPhrase: String = "" {
        didSet {
            updateSeedPhraseArray()
        }
    }
    @Published var seedPhraseArray: [String] = []

    init(walletClient: Binding<WalletClient>) {
        _walletClient = walletClient
        self.lightningClient = walletClient.lightningClient.wrappedValue
    }

    func saveSeed() async {
        await walletClient.createWallet(
            seedPhrase: seedPhrase,
            network: walletClient.network,
            server: walletClient.server
        )
    }

    private func updateSeedPhraseArray() {
        let trimmedWords = seedPhrase.trimmingCharacters(in: .whitespacesAndNewlines)
        seedPhraseArray = trimmedWords.split(separator: " ").map { String($0) }
    }
}
