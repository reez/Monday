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
