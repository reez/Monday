//
//  PeerViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import SwiftUI
import LightningDevKitNode
import WalletUI

class PeerViewModel: ObservableObject {
    @Published var address: SocketAddr = ""
    @Published var errorMessage: MondayNodeError?
    @Published var networkColor = Color.gray
    @Published var nodeId: PublicKey = ""
//    @Published var isPeerFinished: Bool = false
    @Published var isProgressViewShowing: Bool = false

    func connect(
        nodeId: PublicKey,
        address: SocketAddr//,
        //        permanently: Bool
    ) async {
        do {
            try await LightningNodeService.shared.connect(
                nodeId: nodeId,
                address: address,
                permanently: true//permanently
            )
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.errorMessage = .init(title: errorString.title, detail: errorString.detail)
//                self.isPeerFinished = true
                self.isProgressViewShowing = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = .init(title: "Unexpected error", detail: error.localizedDescription)
//                self.isPeerFinished = true
                self.isProgressViewShowing = false
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
