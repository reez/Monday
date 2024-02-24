//
//  PaymentsListView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 6/30/23.
//

import LDKNode
import SwiftUI

struct PaymentsListView: View {
    let payments: [PaymentDetails]
    var groupedPayments: [PaymentStatus: [PaymentDetails]] {
        Dictionary(grouping: payments, by: { $0.status })
    }
    let orderedStatuses: [PaymentStatus] = [.succeeded, .failed, .pending]
    var statusDescriptions: [PaymentStatus: String] {
        [
            .succeeded: "Success",
            .failed: "Failure",
            .pending: "Pending",
        ]
    }
    var statusColors: [PaymentStatus: Color] {
        [
            .succeeded: .green,
            .failed: .red,
            .pending: .yellow,
        ]
    }

    var body: some View {
        List {
            ForEach(orderedStatuses, id: \.self) { status in
                if let payments = groupedPayments[status] {
                    Section(header: Text(statusDescriptions[status] ?? "")) {
                        ForEach(payments, id: \.hash) { payment in
                            VStack {
                                HStack(alignment: .center, spacing: 15) {

                                    VStack(alignment: .leading, spacing: 5.0) {
                                        HStack {
                                            switch payment.direction {
                                            case .inbound:
                                                Image(systemName: "arrow.down")
                                                    .font(.subheadline)
                                                    .bold()
                                            case .outbound:
                                                Image(systemName: "arrow.up")
                                                    .font(.subheadline)
                                                    .bold()
                                            }
                                            HStack {
                                                let paymentAmount = payment.amountMsat ?? 0
                                                let amount = paymentAmount.formattedAmount()
                                                Text("\(amount) sats ")
                                                    .font(.body)
                                                    .bold()
                                            }
                                        }
                                        HStack {
                                            Text("Payment Hash")
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.75)
                                            Text(payment.hash)
                                                .truncationMode(.middle)
                                                .lineLimit(1)
                                                .foregroundColor(.secondary)
                                        }
                                        .font(.caption)
                                        if let preimage = payment.preimage {
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
                }
            }
        }
    }
}

struct PaymentsListItemView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsListView(
            payments: [
                .init(
                    hash: .localizedName(of: .ascii),
                    preimage: nil,
                    secret: nil,
                    amountMsat: nil,
                    direction: .inbound,
                    status: .succeeded,
                    lspFeeLimits: nil  //<#LspFeeLimits?#>
                ),
                .init(
                    hash: .localizedName(of: .ascii),
                    preimage: nil,
                    secret: nil,
                    amountMsat: nil,
                    direction: .inbound,
                    status: .pending,
                    lspFeeLimits: nil  //<#LspFeeLimits?#>
                ),
                .init(
                    hash: .localizedName(of: .ascii),
                    preimage: nil,
                    secret: nil,
                    amountMsat: nil,
                    direction: .inbound,
                    status: .failed,
                    lspFeeLimits: nil  //<#LspFeeLimits?#>
                ),
            ]
        )
        PaymentsListView(
            payments: [
                .init(
                    hash: .localizedName(of: .ascii),
                    preimage: nil,
                    secret: nil,
                    amountMsat: nil,
                    direction: .inbound,
                    status: .succeeded,
                    lspFeeLimits: nil  //<#LspFeeLimits?#>
                ),
                .init(
                    hash: .localizedName(of: .ascii),
                    preimage: nil,
                    secret: nil,
                    amountMsat: nil,
                    direction: .inbound,
                    status: .pending,
                    lspFeeLimits: nil  //<#LspFeeLimits?#>
                ),
                .init(
                    hash: .localizedName(of: .ascii),
                    preimage: nil,
                    secret: nil,
                    amountMsat: nil,
                    direction: .inbound,
                    status: .failed,
                    lspFeeLimits: nil  //<#LspFeeLimits?#>
                ),
            ]
        )
        .environment(\.sizeCategory, .accessibilityLarge)
        PaymentsListView(
            payments: [
                .init(
                    hash: .localizedName(of: .ascii),
                    preimage: nil,
                    secret: nil,
                    amountMsat: nil,
                    direction: .inbound,
                    status: .succeeded,
                    lspFeeLimits: nil  //<#LspFeeLimits?#>
                ),
                .init(
                    hash: .localizedName(of: .ascii),
                    preimage: nil,
                    secret: nil,
                    amountMsat: nil,
                    direction: .inbound,
                    status: .pending,
                    lspFeeLimits: nil  //<#LspFeeLimits?#>
                ),
                .init(
                    hash: .localizedName(of: .ascii),
                    preimage: nil,
                    secret: nil,
                    amountMsat: nil,
                    direction: .inbound,
                    status: .failed,
                    lspFeeLimits: nil  //<#LspFeeLimits?#>
                ),
            ]
        )
        .environment(\.colorScheme, .dark)
    }
}
