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
//    var sections: [PaymentSection]
//    {
//        orderedStatuses.compactMap { status -> PaymentSection? in
//            guard let paymentsForStatus = groupedPayments[status] else { return nil }
//            return PaymentSection(status: status, payments: paymentsForStatus)
//        }
//    }
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
//    var groupedPayments: [PaymentStatus: [PaymentDetails]] {
//        Dictionary(grouping: payments, by: { $0.status })
//    }

    var body: some View {
        List {
            Section {
                ForEach(payments, id: \.id) { payment in
                    //PaymentDetailView(payment: payment)
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

struct PaymentDetailView: View {
    let payment: PaymentDetails

    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 15) {
                VStack(alignment: .leading, spacing: 5.0) {
                    HStack {
                        Image(systemName: payment.direction == .inbound ? "arrow.down" : "arrow.up")
                            .font(.subheadline)
                            .bold()
                        let paymentAmount = payment.amountMsat ?? 0
                        let amount = paymentAmount.formattedAmount()
                        Text("\(amount) sats")
                            .font(.body)
                            .bold()
                    }
                    HStack {
                        Text("Payment ID")
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        Text(payment.id)
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                    .font(.caption)

                    if let preimage = payment.kind.preimageAsString {
                        HStack {
                            Text("Preimage")
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                            Text(preimage)
                                .truncationMode(.middle)
                                .lineLimit(1)
                                .foregroundColor(.secondary)
                        }
                        .font(.caption)
                    }

                    HStack(spacing: 4) {
                        Text("Updated at")
                        Text(
                            Date(
                                timeIntervalSince1970: TimeInterval(payment.latestUpdateTimestamp)
                            ),
                            style: .time
                        )
                    }
                    .fontWeight(.light)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .minimumScaleFactor(0.75)

                }
                Spacer()
            }
            .padding(.all, 10.0)
        }
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
                    systemName: transaction.status == PaymentStatus.pending
                        ? "clock" : transaction.direction == .inbound ? "arrow.down" : "arrow.up"
                )
                .foregroundColor(
                    transaction.status == PaymentStatus.failed
                        ? .bitcoinRed
                        : transaction.status == PaymentStatus.pending
                            ? .bitcoinOrange : .bitcoinNeutral8
                )
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
                transaction.status == PaymentStatus.failed
                    ? .bitcoinRed
                    : transaction.status == PaymentStatus.pending
                        ? .bitcoinOrange
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
