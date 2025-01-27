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
            do {
                self.selectedEsploraServer = availableServers(network: self.selectedNetwork).first!  // all networks have at least one server option
                try keyClient.saveNetwork(selectedNetwork.description)
            } catch {
                debugPrint("Error selecting network")
            }
        }
    }
    @Published var selectedEsploraServer: EsploraServer = EsploraServer.mutiny_signet
    {
        didSet {
            do {
                try keyClient.saveServerURL(selectedEsploraServer.url)
            } catch {
                debugPrint("Error selecting server")
            }
        }
    }

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
