//
//  NetworkSettingsViewModel.swift
//  LDKNodeMonday
//
//  Created by Daniel Nordh on 20/01/2025.
//

import LDKNode
import SwiftUI

class NetworkSettingsViewModel: ObservableObject {
    private let keyClient: KeyClient
    @Binding var walletClient: WalletClient
    @State private var showRestartAlert = false
    @Published var selectedNetwork: Network = .signet {
        didSet {
            //walletClient.appState != .onboarding ? try keyClient.saveNetwork(selectedNetwork.description) : nil
            guard let server = availableServers(network: self.selectedNetwork).first else {
                // This should never happen, but if it does:
                fatalError(
                    "Configuration error: No Esplora servers available for \(self.selectedNetwork)"
                )
            }
            self.selectedEsploraServer = server
        }
    }
    @Published var selectedEsploraServer: EsploraServer = EsploraServer.mutiny_signet

    init(
        walletClient: Binding<WalletClient>,
        keyClient: KeyClient = .live
    ) {
        _walletClient = walletClient
        self.keyClient = keyClient
        self.selectedNetwork = walletClient.network.wrappedValue
        self.selectedEsploraServer = walletClient.server.wrappedValue
    }
}
