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
                self.selectedEsploraServer = availableEsploraServers.first!  // all networks have at least one server option
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
            let backupInfo = try keyClient.getBackupInfo()
            self.selectedNetwork = Network(stringValue: backupInfo.networkString) ?? .signet
            self.selectedEsploraServer = EsploraServer(URLString: backupInfo.serverURL)
            ?? .mutiny_signet
        } catch {
            debugPrint("Error getting network/server")
        }
    }
}
