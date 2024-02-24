//
//  LightningBalanceView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/23/24.
//

import LDKNode
import SwiftUI

struct LightningBalanceView: View {
    let balances: [LightningBalance]

    var body: some View {
        List(balances, id: \.self) { balance in
            VStack(alignment: .leading) {
                switch balance {
                case .claimableOnChannelClose(
                    let channelId,
                    let counterpartyNodeId,
                    let amountSatoshis
                ):
                    Text("Claimable on Channel Close: \(amountSatoshis) sats")
                    Text("Channel ID: \(channelId)")
                    Text("Counterparty Node ID: \(counterpartyNodeId)")
                case .claimableAwaitingConfirmations(
                    let channelId,
                    let counterpartyNodeId,
                    let amountSatoshis,
                    let confirmationHeight
                ):
                    Text("Claimable Awaiting Confirmations: \(amountSatoshis) sats")
                    Text("Channel ID: \(channelId)")
                    Text("Counterparty Node ID: \(counterpartyNodeId)")
                    Text("Confirmation Height: \(confirmationHeight)")
                case .contentiousClaimable(
                    let channelId,
                    let counterpartyNodeId,
                    let amountSatoshis,
                    let timeoutHeight,
                    _,
                    _
                ):
                    Text("Contentious Claimable: \(amountSatoshis) sats")
                    Text("Channel ID: \(channelId)")
                    Text("Counterparty Node ID: \(counterpartyNodeId)")
                    Text("Timeout Height: \(timeoutHeight)")
                case .maybeTimeoutClaimableHtlc(
                    let channelId,
                    let counterpartyNodeId,
                    let amountSatoshis,
                    let claimableHeight,
                    _
                ):
                    Text("Maybe Timeout Claimable HTLC: \(amountSatoshis) sats")
                    Text("Channel ID: \(channelId)")
                    Text("Counterparty Node ID: \(counterpartyNodeId)")
                    Text("Claimable Height: \(claimableHeight)")
                case .maybePreimageClaimableHtlc(
                    let channelId,
                    let counterpartyNodeId,
                    let amountSatoshis,
                    let expiryHeight,
                    _
                ):
                    Text("Maybe Preimage Claimable HTLC: \(amountSatoshis) sats")
                    Text("Channel ID: \(channelId)")
                    Text("Counterparty Node ID: \(counterpartyNodeId)")
                    Text("Expiry Height: \(expiryHeight)")
                case .counterpartyRevokedOutputClaimable(
                    let channelId,
                    let counterpartyNodeId,
                    let amountSatoshis
                ):
                    Text("Counterparty Revoked Output Claimable: \(amountSatoshis) sats")
                    Text("Channel ID: \(channelId)")
                    Text("Counterparty Node ID: \(counterpartyNodeId)")
                }
            }
            .padding()
        }
        .truncationMode(.middle)
        .lineLimit(1)
        .font(.caption)
        .fontDesign(.monospaced)

    }
}

#Preview {
    LightningBalanceView(
        balances: [
            .claimableOnChannelClose(
                channelId: "channel1",
                counterpartyNodeId: "node1",
                amountSatoshis: 10_000
            ),
            .claimableAwaitingConfirmations(
                channelId: "channel2",
                counterpartyNodeId: "node2",
                amountSatoshis: 20_000,
                confirmationHeight: 650_000
            ),
            .contentiousClaimable(
                channelId: "channel3",
                counterpartyNodeId: "node3",
                amountSatoshis: 30_000,
                timeoutHeight: 655_000,
                paymentHash: "hash1",
                paymentPreimage: "preimage1"
            ),
            .maybeTimeoutClaimableHtlc(
                channelId: "channel4",
                counterpartyNodeId: "node4",
                amountSatoshis: 40_000,
                claimableHeight: 660_000,
                paymentHash: "hash2"
            ),
            .maybePreimageClaimableHtlc(
                channelId: "channel5",
                counterpartyNodeId: "node5",
                amountSatoshis: 50_000,
                expiryHeight: 665_000,
                paymentHash: "hash3"
            ),
            .counterpartyRevokedOutputClaimable(
                channelId: "channel6",
                counterpartyNodeId: "node6",
                amountSatoshis: 60_000
            ),
        ]
    )
}
