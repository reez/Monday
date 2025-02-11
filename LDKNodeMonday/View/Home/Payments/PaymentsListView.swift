//
//  PaymentsListView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 6/30/23.
//

import LDKNode
import SwiftUI

struct PaymentSection {
    let status: PaymentStatus
    var payments: [PaymentDetails]
}

struct PaymentsListView: View {
    let payments: [PaymentDetails]
    var sections: [PaymentSection] {
        orderedStatuses.compactMap { status -> PaymentSection? in
            guard let paymentsForStatus = groupedPayments[status] else { return nil }
            return PaymentSection(status: status, payments: paymentsForStatus)
        }
    }
    let orderedStatuses: [PaymentStatus] = [
        .succeeded,
        .pending,
        .failed,
    ]
    var statusDescriptions: [PaymentStatus: String] {
        [
            .succeeded: "Success",
            .pending: "Pending",
            .failed: "Failure",
        ]
    }
    var statusColors: [PaymentStatus: Color] {
        [
            .succeeded: .green,
            .pending: .yellow,
            .failed: .red,
        ]
    }
    var groupedPayments: [PaymentStatus: [PaymentDetails]] {
        Dictionary(grouping: payments, by: { $0.status })
    }

    var body: some View {
        List {
            Section {
                ForEach(payments, id: \.id) { payment in
                    TransactionItemView(transaction: payment)
                        .padding(.vertical, 5)
                        .listRowSeparator(.hidden)
                }
            } header: {
                Text("Activity")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
        .listStyle(.plain)
    }
}

struct TransactionItemView: View {
    var transaction: PaymentDetails

    var body: some View {
        HStack(spacing: 15) {
            let date = Date(timeIntervalSince1970: TimeInterval(transaction.latestUpdateTimestamp))
            ZStack {
                Circle()
                    .fill(Color.bitcoinNeutral1)
                    .frame(width: 40, height: 40)
                Image(
                    systemName: transaction.status == .failed
                        ? "x.circle"
                        : transaction.status == .pending
                            ? "clock"
                            : transaction.direction == .inbound ? "arrow.down" : "arrow.up"
                )
                .foregroundColor(.bitcoinNeutral8)
                .font(.subheadline)
                .fontWeight(.bold)
            }
            VStack(alignment: .leading) {
                Text(
                    transaction.status == PaymentStatus.failed
                        ? "Failed"
                        : transaction.status == PaymentStatus.pending
                            ? "Pending" : transaction.direction == .inbound ? "Received" : "Sent"
                )
                .font(.subheadline)
                .fontWeight(.semibold)
                Text(date.formatted(date: .abbreviated, time: .shortened))
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Spacer()
            let paymentAmount = transaction.amountMsat ?? 0
            let amount = paymentAmount.formattedAmount()
            Text(
                (transaction.direction == .inbound ? "+ " : "- ")
                    + amount
            )
            .font(.system(size: 18, weight: .regular))
            .foregroundColor(
                transaction.status == .failed
                    ? .bitcoinNeutral4
                    : transaction.status == .pending
                        ? .bitcoinNeutral4
                        : transaction.direction == .inbound ? .bitcoinGreen : .bitcoinNeutral8
            )
        }
    }
}

#if DEBUG
    #Preview {
        PaymentsListView(
            payments: mockPayments
        )
    }
#endif
