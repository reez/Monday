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
            ForEach(sections, id: \.status) { section in
                Section(header: Text(statusDescriptions[section.status] ?? "")) {
                    ForEach(section.payments, id: \.id) { payment in
                        VStack {
                            HStack(alignment: .center, spacing: 15) {
                                VStack(alignment: .leading, spacing: 5.0) {
                                    PaymentDetailView(payment: payment)
                                }
                                Spacer()
                            }
                            .padding(.all, 10.0)
                        }
                    }
                }
            }
        }
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
                        Text("Payment Hash")
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

                }
                Spacer()
            }
            .padding(.all, 10.0)
        }
    }

}

struct PaymentsListItemView_Previews: PreviewProvider {
    static var previews: some View {

        PaymentsListView(
            payments: [
                .init(
                    id: .localizedName(of: .ascii),
                    kind: .bolt11(hash: .localizedName(of: .ascii), preimage: nil, secret: nil),
                    amountMsat: nil,
                    direction: .inbound,
                    status: .succeeded
                ),
                .init(
                    id: .localizedName(of: .ascii),
                    kind: .bolt11(hash: .localizedName(of: .ascii), preimage: nil, secret: nil),
                    amountMsat: nil,
                    direction: .inbound,
                    status: .pending
                ),
                .init(
                    id: .localizedName(of: .ascii),
                    kind: .bolt11(hash: .localizedName(of: .ascii), preimage: nil, secret: nil),
                    amountMsat: nil,
                    direction: .inbound,
                    status: .failed
                ),
            ]
        )

        PaymentsListView(
            payments: [
                .init(
                    id: .localizedName(of: .ascii),
                    kind: .bolt11(hash: .localizedName(of: .ascii), preimage: nil, secret: nil),
                    amountMsat: nil,
                    direction: .inbound,
                    status: .succeeded
                ),
                .init(
                    id: .localizedName(of: .ascii),
                    kind: .bolt11(hash: .localizedName(of: .ascii), preimage: nil, secret: nil),
                    amountMsat: nil,
                    direction: .inbound,
                    status: .pending
                ),
                .init(
                    id: .localizedName(of: .ascii),
                    kind: .bolt11(hash: .localizedName(of: .ascii), preimage: nil, secret: nil),
                    amountMsat: nil,
                    direction: .inbound,
                    status: .failed
                ),
            ]
        )
        .environment(\.sizeCategory, .accessibilityLarge)

        PaymentsListView(
            payments: [
                .init(
                    id: .localizedName(of: .ascii),
                    kind: .bolt11(hash: .localizedName(of: .ascii), preimage: nil, secret: nil),
                    amountMsat: nil,
                    direction: .inbound,
                    status: .succeeded
                ),
                .init(
                    id: .localizedName(of: .ascii),
                    kind: .bolt11(hash: .localizedName(of: .ascii), preimage: nil, secret: nil),
                    amountMsat: nil,
                    direction: .inbound,
                    status: .pending
                ),
                .init(
                    id: .localizedName(of: .ascii),
                    kind: .bolt11(hash: .localizedName(of: .ascii), preimage: nil, secret: nil),
                    amountMsat: nil,
                    direction: .inbound,
                    status: .failed
                ),
            ]
        )
        .environment(\.colorScheme, .dark)

    }
}
