//
//  ChannelsListViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import LDKNode
import SwiftUI

@Observable
@MainActor
class ChannelsListViewModel {
    let nodeInfoClient: NodeInfoClient
    var channelsListViewError: MondayError?
    var aliases = [String: String]()
    var channels: [ChannelDetails] = []
    var networkColor = Color.gray

    init(nodeInfoClient: NodeInfoClient) {
        self.nodeInfoClient = nodeInfoClient
    }

    func listChannels() async {
        self.channels = LightningNodeService.shared.listChannels()

        // Open Issue https://github.com/lightningdevkit/ldk-node/issues/234
        // Temporary: if mainnet then get alias, ignore if other networks
        if LightningNodeService.shared.network == Network.bitcoin {
            for channel in channels {
                await fetchAlias(for: channel.counterpartyNodeId)
            }
        }
    }

    func fetchAlias(for nodeId: String) async {
        do {
            let info = try await nodeInfoClient.fetchNodeInfo(nodeId)
            if let alias = info.nodes.first?.alias {
                self.aliases[nodeId] = alias
            }
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            self.channelsListViewError = .init(title: errorString.title, detail: errorString.detail)
        } catch {
            self.channelsListViewError = .init(
                title: "Unexpected error",
                detail: error.localizedDescription
            )
        }
    }

    func getColor() {
        let color = LightningNodeService.shared.networkColor
        DispatchQueue.main.async {
            self.networkColor = color
        }
    }

}
