//
//  LightningNodeInfo.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 1/31/24.
//

import Foundation

struct LightningNodeInfo: Codable {
    let nodes: [Node]
    let channels: [Channel]

    struct Node: Codable {
        let publicKey: String
        let alias: String
        let capacity: Int?
        let channels: Int?

        enum CodingKeys: String, CodingKey {
            case publicKey = "public_key"
            case alias
            case capacity
            case channels
        }
    }

    struct Channel: Codable {
        let channelId: String
        let node1Pub: String
        let node2Pub: String
        let capacity: Int

        enum CodingKeys: String, CodingKey {
            case channelId = "channel_id"
            case node1Pub = "node1_pub"
            case node2Pub = "node2_pub"
            case capacity
        }
    }
}

#if DEBUG
    let nodeMock = LightningNodeInfo.Node(
        publicKey: "publicKey",
        alias: "alias",
        capacity: 1,
        channels: 1
    )
    let channelMock = LightningNodeInfo.Channel(
        channelId: "channelId",
        node1Pub: "node1Pub",
        node2Pub: "node2Pub",
        capacity: 100
    )
    let nodeInfoMock = LightningNodeInfo(
        nodes: [nodeMock],
        channels: [channelMock]
    )
#endif
