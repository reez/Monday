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
    @Published var nodeIDError: MondayError?
    @Published var networkColor = Color.gray
    @Published var nodeID: String = ""
    @AppStorage("isOnboarding") var isOnboarding: Bool?

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
            // Stop Node...
            try LightningNodeService.shared.stop()
            // ... then Delete Wallet
            try LightningNodeService.shared.deleteWallet()
            // Delete network and URL settings using KeyClient
            try KeyClient.live.deleteNetwork()
            try KeyClient.live.deleteEsplora()
            // ... then set isOnboarding to true
            self.isOnboarding = true
            // ... which should send you back to OnboardingView
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

    func onboarding() {
        do {
            // Stop Node...
            try LightningNodeService.shared.stop()
            // Delete network and URL settings using KeyClient
            try KeyClient.live.deleteNetwork()
            try KeyClient.live.deleteEsplora()
            // ... then set isOnboarding to true
            self.isOnboarding = true
            // ... which should send you back to OnboardingView
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
