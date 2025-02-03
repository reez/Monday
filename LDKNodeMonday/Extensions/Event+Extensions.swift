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

        case .paymentSuccessful(_, let paymentHash, _, _):
            return "Payment Successful \(paymentHash.truncated(toLength: 10))"

        case .paymentFailed(_, let paymentHash, let paymentFailureReason):
            return
                "Payment Failed \(paymentFailureReason.debugDescription) \(String(describing: paymentHash?.truncated(toLength: 10)))"

        case .paymentReceived(_, _, let amountMsat, _):
            let formatted = amountMsat.formattedAmount()
            return "Payment Received \(formatted) sats"

        case .channelPending(_, _, _, let counterpartyNodeId, _):
            return "Channel Pending \(counterpartyNodeId.truncated(toLength: 10))"

        case .channelReady(_, _, let counterpartyNodeId):
            return "Channel Ready \(counterpartyNodeId?.truncated(toLength: 10) ?? "")"

        case .channelClosed(_, _, let counterpartyNodeId, let reason):
            let debugReason = reason.debugDescription
            return
                "Channel Closed \(debugReason) \(counterpartyNodeId?.truncated(toLength: 10) ?? "")"

        case .paymentForwarded(
            let prevChannelId,
            let nextChannelId,
            let prevUserChannelId,
            let nextUserChannelId,
            let prevNodeId,
            let nextNodeId,
            let totalFeeEarnedMsat,
            let skimmedFeeMsat,
            let claimFromOnchainTx,
            let outboundAmountForwardedMsat
        ):
            return "Payment Forwarded"

        case .paymentClaimable(
            let paymentId,
            let paymentHash,
            let claimableAmountMsat,
            let claimDeadline,
            let customRecords
        ):
            return "Payment Claimable \(paymentHash.truncated(toLength: 10))"

        }

    }

}
