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
    let lightningClient: LightningNodeClient
    private let keyClient: KeyClient
    var channelsListViewError: MondayError?
    var aliases = [String: String]()
    var channels: [ChannelDetails] = []

    init(
        nodeInfoClient: NodeInfoClient,
        keyClient: KeyClient = .live,
        lightningClient: LightningNodeClient
    ) {
        self.nodeInfoClient = nodeInfoClient
        self.keyClient = keyClient
        self.lightningClient = lightningClient
    }

    func listChannels() async {
        self.channels = lightningClient.listChannels()

        // Open Issue https://github.com/lightningdevkit/ldk-node/issues/234
        // Temporary: if mainnet then get alias, ignore if other networks
        if let networkString = try? keyClient.getNetwork(),
            networkString == Network.bitcoin.description
        {
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

}
