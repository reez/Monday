//
//  ChannelCloseViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import SwiftUI
import LightningDevKitNode

class ChannelCloseViewModel: ObservableObject {
    @Published var channel: ChannelDetails
    @Published var errorMessage: MondayNodeError?
    @Published var networkColor = Color.gray
    
    init(channel: ChannelDetails) {
        self.channel = channel
    }
    
    func close() {
        do {
            try LightningNodeService.shared.closeChannel(
                channelId: self.channel.channelId,
                counterpartyNodeId: self.channel.counterpartyNodeId
            )
            errorMessage = nil
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.errorMessage = .init(title: errorString.title, detail: errorString.detail)
            }
        } catch {
            DispatchQueue.main.async {
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
