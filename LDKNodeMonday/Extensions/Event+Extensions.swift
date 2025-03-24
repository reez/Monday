//
//  Event+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 12/23/23.
//

import Foundation
import LDKNode
import SwiftUI

extension Event {

    public var title: String {
        switch self {
        case .paymentSuccessful:
            return "Payment Sent"
        case .paymentReceived:
            return "Payment Received"
        case .paymentFailed:
            return "Payment Failed"
        case .channelReady:
            return "Channel Opened"
        case .channelClosed:
            return "Channel Closed"
        case .channelPending:
            return "Channel Pending"
        default:
            return ""
        }
    }

    public var description: String {

        switch self {

        case .paymentSuccessful(_, let paymentHash, _):
            return "Payment Successful \(paymentHash.truncated(toLength: 10))"

        case .paymentFailed(_, let paymentHash, let paymentFailureReason):
            return
                "Payment Failed \(paymentFailureReason.debugDescription) \(String(describing: paymentHash?.truncated(toLength: 10)))"

        case .paymentReceived(_, _, let amountMsat):
            let formatted = amountMsat.mSatsAsSats.formatted(.number.notation(.automatic))
            return "Payment Received \(formatted) sats"

        case .channelPending(_, _, _, let counterpartyNodeId, _):
            return "Channel Pending \(counterpartyNodeId.truncated(toLength: 10))"

        case .channelReady(_, _, let counterpartyNodeId):
            return "Channel Ready \(counterpartyNodeId?.truncated(toLength: 10) ?? "")"

        case .channelClosed(_, _, let counterpartyNodeId, let reason):
            let debugReason = reason.debugDescription
            return
                "Channel Closed \(debugReason) \(counterpartyNodeId?.truncated(toLength: 10) ?? "")"

        case .paymentClaimable(_, let paymentHash, _, _):
            return "Payment Claimable \(paymentHash.truncated(toLength: 10))"
        }

    }

    public var iconName: String {
        switch self {
        case .paymentSuccessful:
            return "arrow.up"
        case .paymentReceived:
            return "arrow.down"
        case .paymentFailed:
            return "x.circle"
        case .channelReady:
            return "checkmark.circle"
        case .channelClosed:
            return "x.circle"
        default:
            return "info.circle"
        }
    }

    public var amount: UInt64 {
        switch self {
        case .paymentReceived(_, _, let amountMsat):
            return amountMsat.mSatsAsSats
        default:
            return 0
        }
    }
}

struct EventItemView: View {
    var event: Event?
    var price: Double

    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.bitcoinNeutral2)
                    .frame(width: 40, height: 40)
                Image(systemName: event?.iconName ?? "info.circle")
                    .font(.system(.body, weight: .bold))
                    .foregroundColor(.bitcoinNeutral6)
            }

            VStack(alignment: .leading) {
                Text(event?.title ?? "Title")
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundColor(.bitcoinNeutral8)
                Text("Just now")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.bitcoinNeutral6)
            }

            Spacer()

            VStack(alignment: .trailing) {
                if let amount = event?.amount, amount != 0 {
                    Text("+ \(amount.formatted(.number.notation(.automatic)))")
                        .font(.system(.body, design: .rounded, weight: .medium))
                        .foregroundColor(.bitcoinGreen)
                    Text(event?.amount.formattedSatsAsUSD(price: price) ?? "")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.bitcoinNeutral6)
                }
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(Capsule())
        .shadow(color: Color.bitcoinNeutral5.opacity(0.8), radius: 4, x: 0, y: 2)
        .lineLimit(1)
        .minimumScaleFactor(0.75)
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)  // Sets max dynamic size for all Text
    }
}
