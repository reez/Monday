//
//  DisconnectViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import SwiftUI
import LightningDevKitNode

class DisconnectViewModel: ObservableObject {
    @Published var nodeError: MondayError?
    @Published var networkColor = Color.gray
    @Published var nodeId: PublicKey
    
    init(nodeId: PublicKey) {
        self.nodeId = nodeId
    }
    
    func disconnect() {
        do {
            try LightningNodeService.shared.disconnect(nodeId: self.nodeId)
            nodeError = nil
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.nodeError = .init(title: errorString.title, detail: errorString.detail)
            }
        } catch {
            DispatchQueue.main.async {
                self.nodeError = .init(title: "Unexpected error", detail: error.localizedDescription)
            }
        }
    }
    
    func getColor() {
        let color = LightningNodeService.shared.networkColor
        DispatchQueue.main.async {
            self.networkColor = color
        }
    }
    
}
