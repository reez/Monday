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

    private let lightningClient: LightningNodeClient

    init(lightningClient: LightningNodeClient) {
        self.lightningClient = lightningClient
    }

    func connect(
        nodeId: PublicKey,
        address: String
    ) async {
        do {
            try await lightningClient.connect(
                nodeId,
                address,
                true
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
