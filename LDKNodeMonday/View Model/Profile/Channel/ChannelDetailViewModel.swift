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
    private let lightningClient: LightningNodeClient

    init(
        channel: ChannelDetails,
        lightningClient: LightningNodeClient
    ) {
        self.channel = channel
        self.lightningClient = lightningClient
    }

    func close() {
        do {
            try lightningClient.closeChannel(
                self.channel.userChannelId,
                self.channel.counterpartyNodeId
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
