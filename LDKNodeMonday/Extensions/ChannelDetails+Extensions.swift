//
//  ChannelDetails+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 12/13/23.
//

import Foundation
import LDKNode

extension ChannelDetails: Hashable {
    public static func == (lhs: ChannelDetails, rhs: ChannelDetails) -> Bool {
        return lhs.channelId == rhs.channelId
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(channelId)
    }
}
