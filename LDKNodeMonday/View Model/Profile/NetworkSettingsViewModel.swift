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
    @Published var selectedNetwork: Network = .signet {
        didSet {
            do {
                let networkString = selectedNetwork.description
                try keyClient.saveNetwork(networkString)
                self.selectedEsploraServer =
                    availableEsploraServers.first ?? EsploraServer(name: "", url: "")
                try keyClient.saveEsploraURL(selectedEsploraServer.url)
            } catch {
                DispatchQueue.main.async {
                    /*
                    self.onboardingViewError = .init(
                        title: "Error Selecting Network",
                        detail: error.localizedDescription
                    )
                     */
                }
            }
        }
    }
    @Published var selectedEsploraServer: EsploraServer = EsploraServer.mutiny_signet
    {
        didSet {
            do {
                try keyClient.saveEsploraURL(selectedEsploraServer.url)
            } catch {
                DispatchQueue.main.async {
                    /*
                    self.onboardingViewError = .init(
                        title: "Error Selecting Esplora",
                        detail: error.localizedDescription
                    )
                     */
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

    init(
        keyClient: KeyClient = .live
    ) {
        self.keyClient = keyClient

        do {
            if let networkString = try keyClient.getNetwork() {
                self.selectedNetwork = Network(stringValue: networkString) ?? .signet
            }
            if let esploraURL = try keyClient.getEsploraURL() {
                self.selectedEsploraServer =
                    availableEsploraServers.first(where: {
                        $0.url == esploraURL
                    }) ?? EsploraServer.mutiny_signet
            }
        } catch {
            /*
            DispatchQueue.main.async {
                self.onboardingViewError = .init(
                    title: "Error Getting Network/Esplora",
                    detail: error.localizedDescription
                )
            }
            */
        }
    }
}
