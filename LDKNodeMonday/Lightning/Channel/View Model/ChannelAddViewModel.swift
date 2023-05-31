//
//  ChannelAddViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import SwiftUI
import LightningDevKitNode
import CodeScanner

class ChannelAddViewModel: ObservableObject {
    @Published var address: SocketAddr = ""
    @Published var channelAmountSats: String = ""
    @Published var errorMessage: MondayNodeError?
    @Published var networkColor = Color.gray
    @Published var nodeId: PublicKey = ""
    @Published var isOpenChannelFinished: Bool = false
    @Published var isProgressViewShowing: Bool = false
    
    func openChannel(nodeId: PublicKey, address: SocketAddr, channelAmountSats: UInt64, pushToCounterpartyMsat: UInt64?) async {
        DispatchQueue.main.async {
            self.isProgressViewShowing = true
        }
        do {
            try await LightningNodeService.shared.connectOpenChannel(
                nodeId: nodeId,
                address: address,
                channelAmountSats: channelAmountSats,
                pushToCounterpartyMsat: pushToCounterpartyMsat
            )
            DispatchQueue.main.async {
                self.errorMessage = nil
                self.isOpenChannelFinished = true
                self.isProgressViewShowing = false
            }
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.isProgressViewShowing = false
                self.errorMessage = .init(title: errorString.title, detail: errorString.detail)
            }
        } catch {
            DispatchQueue.main.async {
                self.isProgressViewShowing = false
                self.errorMessage = .init(title: "Unexpected error", detail: error.localizedDescription)
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
