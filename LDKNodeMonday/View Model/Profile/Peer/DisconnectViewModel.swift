//
//  DisconnectViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import LDKNode
import SwiftUI

class DisconnectViewModel: ObservableObject {
    @Published var disconnectViewError: MondayError?
    @Published var nodeId: PublicKey
    private let lightningClient: LightningNodeClient

    init(
        nodeId: PublicKey,
        lightningClient: LightningNodeClient
    ) {
        self.nodeId = nodeId
        self.lightningClient = lightningClient
    }

    func disconnect() async {
        do {
            try lightningClient.disconnect(self.nodeId)
            disconnectViewError = nil
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.disconnectViewError = .init(
                    title: errorString.title,
                    detail: errorString.detail
                )
            }
        } catch {
            DispatchQueue.main.async {
                self.disconnectViewError = .init(
                    title: "Unexpected error",
                    detail: error.localizedDescription
                )
            }
        }
    }
}
