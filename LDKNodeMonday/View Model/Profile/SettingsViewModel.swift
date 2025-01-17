//
//  NodeIDViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import BitcoinUI
import LDKNode
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Binding var appState: AppState
    @Published var nodeIDError: MondayError?
    @Published var nodeID: String = ""
    @Published var network: String?
    @Published var esploraURL: String?
    @Published var status: NodeStatus?
    @Published var isStatusFinished: Bool = false
    let keyClient: KeyClient

    init(appState: Binding<AppState>, keyClient: KeyClient = .live) {
        _appState = appState
        self.keyClient = keyClient
    }

    func getNodeID() {
        let nodeID = LightningNodeService.shared.nodeId()
        self.nodeID = nodeID
    }

    func stop() {
        do {
            try LightningNodeService.shared.stop()
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.nodeIDError = .init(title: errorString.title, detail: errorString.detail)
            }
        } catch {
            DispatchQueue.main.async {
                self.nodeIDError = .init(
                    title: "Unexpected error",
                    detail: error.localizedDescription
                )
            }
        }
    }

    func delete() {
        if network != nil {
            do {
                DispatchQueue.main.async {
                    self.appState = .loading
                }
                try LightningNodeService.shared.stop()
                try LightningNodeService.shared.deleteDocuments(network: network!)
                try LightningNodeService.shared.deleteWallet()
                try KeyClient.live.deleteNetwork()
                try KeyClient.live.deleteEsplora()
                DispatchQueue.main.async {
                    self.appState = .onboarding
                }
            } catch let error as NodeError {
                let errorString = handleNodeError(error)
                DispatchQueue.main.async {
                    self.nodeIDError = .init(title: errorString.title, detail: errorString.detail)
                }
            } catch {
                DispatchQueue.main.async {
                    self.appState = .error
                }
            }
        } else {
            debugPrint("No Network found, so not deleting")
        }

    }

    func getNetwork() {
        do {
            self.network = try keyClient.getNetwork()
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.nodeIDError = .init(title: errorString.title, detail: errorString.detail)
            }
        } catch {
            DispatchQueue.main.async {
                self.nodeIDError = .init(
                    title: "Unexpected error",
                    detail: error.localizedDescription
                )
            }
        }
    }

    func getEsploraUrl() {
        do {
            self.esploraURL = try keyClient.getEsploraURL()
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.nodeIDError = .init(title: errorString.title, detail: errorString.detail)
            }
        } catch {
            DispatchQueue.main.async {
                self.nodeIDError = .init(
                    title: "Unexpected error",
                    detail: error.localizedDescription
                )
            }
        }
    }

    func getStatus() async {
        let status = LightningNodeService.shared.status()
        DispatchQueue.main.async {
            self.status = status
            self.isStatusFinished = true
        }
    }

}
