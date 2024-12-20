//
//  PeerViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import LDKNode
import SwiftUI

class PeerViewModel: ObservableObject {
    @Published var address: String = ""
    @Published var peerViewError: MondayError?
    @Published var nodeId: PublicKey = ""
    @Published var isProgressViewShowing: Bool = false

    func connect(
        nodeId: PublicKey,
        address: String
    ) async {
        do {
            try await LightningNodeService.shared.connect(
                nodeId: nodeId,
                address: address,
                persist: true
            )
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.peerViewError = .init(title: errorString.title, detail: errorString.detail)
                self.isProgressViewShowing = false
            }
        } catch {
            DispatchQueue.main.async {
                self.peerViewError = .init(
                    title: "Unexpected error",
                    detail: error.localizedDescription
                )
                self.isProgressViewShowing = false
            }
        }

    }

}
