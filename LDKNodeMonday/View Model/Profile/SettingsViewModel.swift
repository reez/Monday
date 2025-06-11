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
    @Binding var walletClient: WalletClient
    @Published var nodeIDError: MondayError?
    @Published var nodeID: String = ""
    @Published var network: String?
    @Published var esploraURL: String?
    @Published var status: NodeStatus?
    @Published var isStatusFinished: Bool = false
    @Published var currentLSP: LightningServiceProvider

    let lightningClient: LightningNodeClient
    let keyClient: KeyClient

    init(
        walletClient: Binding<WalletClient>,
        keyClient: KeyClient = .live,
        lightningClient: LightningNodeClient
    ) {
        _walletClient = walletClient
        self.keyClient = keyClient
        self.lightningClient = lightningClient
        self.currentLSP = walletClient.wrappedValue.lsp

        // Call these immediately to populate data, wasnt immediately doing it otherwise?
        getNodeID()
        getNetwork()
        getServerUrl()
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

    func getNetwork() {
        do {
            let network = try keyClient.getNetwork()
            DispatchQueue.main.async {
                self.network = network
            }
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

    func getServerUrl() {
        do {
            let url = try keyClient.getServerURL()
            DispatchQueue.main.async {
                self.esploraURL = url
            }
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
