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

        case .paymentSuccessful(paymentId: _, let paymentHash, feePaidMsat: _):
            let truncatedHash = paymentHash.truncated(toLength: 10)
            return "Payment Successful \(truncatedHash)"

        case .paymentFailed(paymentId: _, let paymentHash, let reason):
            let truncatedHash = paymentHash.truncated(toLength: 10)
            let debugReason = reason.debugDescription
            return "Payment Failed \(debugReason) \(truncatedHash))"

        case .paymentReceived(paymentId: _, paymentHash: _, let amountMsat):
            let formattedAmount = amountMsat.formattedAmount()
            return "Payment Received \(formattedAmount) sats"

        case .channelPending(_, _, _, let counterpartyNodeId, _):
            return "Channel Pending \(counterpartyNodeId.truncated(toLength: 10))"

        case .channelReady(_, _, let counterpartyNodeId):
            return "Channel Ready \(counterpartyNodeId?.truncated(toLength: 10) ?? "")"

        case .channelClosed(_, _, let counterpartyNodeId, let reason):
            let debugReason = reason.debugDescription
            return
                "Channel Closed \(debugReason) \(counterpartyNodeId?.truncated(toLength: 10) ?? "")"

        }

    }

}
