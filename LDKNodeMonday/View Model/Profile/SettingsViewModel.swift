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

    let lightningClient: LightningNodeClient
    let keyClient: KeyClient

    init(
        appState: Binding<AppState>,
        keyClient: KeyClient = .live,
        lightningClient: LightningNodeClient
    ) {
        _appState = appState
        self.keyClient = keyClient
        self.lightningClient = lightningClient

        // Call these immediately to populate data, wasnt immediately doing it otherwise?
        getNodeID()
        getNetwork()
        getEsploraUrl()
        Task {
            await getStatus()
        }
    }

    func getNodeID() {
        let nodeID = lightningClient.nodeId()
        self.nodeID = nodeID
    }

    func stop() {
        do {
            try lightningClient.stop()
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
        do {
            if lightningClient.status().isRunning {
                try lightningClient.stop()
            }
            try lightningClient.deleteDocuments()
            try lightningClient.deleteWallet()
            try self.keyClient.deleteNetwork()
            try self.keyClient.deleteEsplora()

            DispatchQueue.main.async {
                self.appState = .onboarding
            }
        } catch let error {
            if let nodeError = error as? NodeError {
                let errorString = handleNodeError(nodeError)
                DispatchQueue.main.async {
                    self.nodeIDError = .init(title: errorString.title, detail: errorString.detail)
                }
            } else {
                DispatchQueue.main.async {
                    self.nodeIDError = .init(title: "Error", detail: error.localizedDescription)
                }
            }
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
        let status = lightningClient.status()
        await MainActor.run {
            self.status = status
            self.isStatusFinished = true
        }
    }
}
