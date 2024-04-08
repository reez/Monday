//
//  NodeIDViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import BitcoinUI
import LDKNode
import SwiftUI

class NodeIDViewModel: ObservableObject {
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    @Published var nodeIDError: MondayError?
    @Published var networkColor = Color.gray
    @Published var nodeID: String = ""
    @Published var network: String?
    @Published var esploraURL: String?
    @Published var status: NodeStatus?
    @Published var isStatusFinished: Bool = false
    let keyClient: KeyClient

    init(keyClient: KeyClient = .live) {
        self.keyClient = keyClient
    }

    func getNodeID() {
        let nodeID = LightningNodeService.shared.nodeId()
        self.nodeID = nodeID
    }

    func getColor() {
        let color = LightningNodeService.shared.networkColor
        DispatchQueue.main.async {
            self.networkColor = color
        }
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
        do {
            try LightningNodeService.shared.stop()
            try LightningNodeService.shared.deleteWallet()
            try KeyClient.live.deleteNetwork()
            try KeyClient.live.deleteEsplora()
            try LightningNodeService.shared.deleteDocuments()
            self.isOnboarding = true
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

    func onboarding() {
        do {
            try LightningNodeService.shared.stop()
            try KeyClient.live.deleteNetwork()
            try KeyClient.live.deleteEsplora()
            self.isOnboarding = true
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

}
