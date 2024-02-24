//
//  PendingSweepBalanceView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/23/24.
//

import LDKNode
import SwiftUI

struct PendingSweepBalanceView: View {
    let balances: [PendingSweepBalance]

    var body: some View {
        List(balances, id: \.self) { balance in
            VStack(alignment: .leading) {
                switch balance {
                case .pendingBroadcast(let channelId, let amountSatoshis):
                    Text("Pending Broadcast: \(amountSatoshis) sats").font(.caption)
                    if let channelId = channelId {
                        Text("Channel ID: \(channelId)").font(.caption)
                    }
                case .broadcastAwaitingConfirmation(
                    let channelId,
                    let latestBroadcastHeight,
                    let latestSpendingTxid,
                    let amountSatoshis
                ):
                    Text("Broadcast Awaiting Confirmation: \(amountSatoshis) sats").font(.caption)
                    if let channelId = channelId {
                        Text("Channel ID: \(channelId)").font(.caption)
                    }
                    Text("Latest Broadcast Height: \(latestBroadcastHeight)").font(.caption)
                    Text("Latest Spending Txid: \(latestSpendingTxid)").font(.caption)
                case .awaitingThresholdConfirmations(
                    let channelId,
                    let latestSpendingTxid,
                    let confirmationHash,
                    let confirmationHeight,
                    let amountSatoshis
                ):
                    Text("Awaiting Threshold Confirmations: \(amountSatoshis) sats").font(.caption)
                    if let channelId = channelId {
                        Text("Channel ID: \(channelId)").font(.caption)
                    }
                    Text("Latest Spending Txid: \(latestSpendingTxid)").font(.caption)
                    Text("Confirmation Hash: \(confirmationHash)").font(.caption)
                    Text("Confirmation Height: \(confirmationHeight)").font(.caption)
                }
            }
            .padding()
        }
    }
}

#Preview {
    PendingSweepBalanceView(
        balances: [
            .pendingBroadcast(channelId: "channel1", amountSatoshis: 10_000),
            .broadcastAwaitingConfirmation(
                channelId: "channel2",
                latestBroadcastHeight: 650_000,
                latestSpendingTxid: "txid1",
                amountSatoshis: 20_000
            ),
            .awaitingThresholdConfirmations(
                channelId: nil,
                latestSpendingTxid: "txid2",
                confirmationHash: "blockhash1",
                confirmationHeight: 660_000,
                amountSatoshis: 30_000
            ),
        ]
    )
}
