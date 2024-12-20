//
//  ChannelCloseViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import LDKNode
import SwiftUI

class ChannelDetailViewModel: ObservableObject {
    @Published var channel: ChannelDetails
    @Published var channelDetailViewError: MondayError?

    init(channel: ChannelDetails) {
        self.channel = channel
    }

    func close() {
        do {
            try LightningNodeService.shared.closeChannel(
                userChannelId: self.channel.userChannelId,
                counterpartyNodeId: self.channel.counterpartyNodeId
            )
            channelDetailViewError = nil
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.channelDetailViewError = .init(
                    title: errorString.title,
                    detail: errorString.detail
                )
            }
        } catch {
            DispatchQueue.main.async {
                self.channelDetailViewError = .init(
                    title: "Unexpected error",
                    detail: error.localizedDescription
                )
            }
        }
    }

}
