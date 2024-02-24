//
//  Event+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 12/23/23.
//

import Foundation
import LDKNode

extension Event: CustomStringConvertible {
    public var description: String {
        switch self {
        case .paymentSuccessful(let paymentHash):
            return "Payment Successful \(paymentHash.truncated(toLength: 10))"
        case .paymentFailed(let paymentHash, let paymentFailureReason):
            return
                "Payment Failed \(paymentFailureReason.debugDescription) \(paymentHash.truncated(toLength: 10))"
        case .paymentReceived(_, let amountMsat):
            return "Payment Received \(amountMsat)"
        case .channelPending(_, _, _, let counterpartyNodeId, _):
            return "Channel Pending \(counterpartyNodeId.truncated(toLength: 10))"
        case .channelReady(_, _, let counterpartyNodeId):
            return "Channel Ready \(counterpartyNodeId?.truncated(toLength: 10) ?? "")"
        case .channelClosed(let channelId, let userChannelId, let counterpartyNodeId, let reason):
            return
                "Channel Closed \(reason.debugDescription) \(counterpartyNodeId?.truncated(toLength: 10) ?? "")"
        }
    }
}
