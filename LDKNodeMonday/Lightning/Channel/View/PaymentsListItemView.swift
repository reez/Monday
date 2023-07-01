//
//  PaymentsListItemView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 6/30/23.
//

import SwiftUI
import LDKNode

struct PaymentsListItemView: View {
    let payments: [PaymentDetails]
    let networkColor: Color
    var groupedPayments: [PaymentStatus: [PaymentDetails]] {
        Dictionary(grouping: payments, by: { $0.status })
    }
    let orderedStatuses: [PaymentStatus] = [.succeeded, .failed, .pending]
    var statusDescriptions: [PaymentStatus: String] {
         [
             .succeeded: "Success",
             .failed: "Failure",
             .pending: "Pending"
         ]
     }
    var statusColors: [PaymentStatus: Color] {
           [
            .succeeded: .green,
               .failed: .red,
               .pending: .yellow
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
                                    ZStack {
                                        Circle()
                                            .frame(width: 35.0, height: 35.0)
//                                            .foregroundColor(networkColor)
                                            .foregroundColor(statusColors[status])
                                        switch payment.direction {
                                        case .inbound:
                                            Image(systemName: "arrow.down")
                                                .font(.subheadline)
                                                .foregroundColor(Color(uiColor: .systemBackground))
                                                .bold()
                                        case .outbound:
                                            Image(systemName: "arrow.up")
                                                .font(.subheadline)
                                                .foregroundColor(Color(uiColor: .systemBackground))
                                                .bold()
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 5.0) {
                                        HStack {
                                            let amountMsat = payment.amountMsat ?? 0
                                            let amountSats = amountMsat / 1000
                                            let amount = amountSats.formattedAmount()
                                            Text("\(amount) sats ")
                                                .font(.body)
                                                .bold()
                                        }
                                        HStack {
                                            Text("Payment Hash")
                                            Text(payment.hash)
                                                .truncationMode(.middle)
                                                .lineLimit(1)
                                                .foregroundColor(.secondary)
                                        }
                                        .font(.caption)
                                        if let preimage = payment.preimage {
                                            HStack {
                                                Text("Preimage")
                                                Text(preimage)
                                                    .truncationMode(.middle)
                                                    .lineLimit(1)
                                                    .foregroundColor(.secondary)
                                            }
                                            .font(.caption)
                                        }
//                                        VStack {
//                                            switch LightningPaymentStatus(payment.status) {
//                                            case .pending:
//                                                Text("Pending")
//                                                    .font(.caption)
//                                                    .foregroundColor(.gray)
//                                            case .succeeded:
//                                                Text("Succeeded")
//                                                    .font(.caption)
//                                                    .foregroundColor(.green)
//                                            case .failed:
//                                                Text("Failed")
//                                                    .font(.caption)
//                                                    .foregroundColor(.red)
//                                            }
//                                        }
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
//        PaymentsListItemView(
//            paymentDetails:
//                [
//                    .init(hash: .localizedName(of: .ascii), preimage: nil, secret: nil, amountMsat: nil, direction: .inbound, status: .succeeded),
//                    .init(hash: .localizedName(of: .ascii), preimage: nil, secret: nil, amountMsat: nil, direction: .inbound, status: .pending),
//                    .init(hash: .localizedName(of: .ascii), preimage: nil, secret: nil, amountMsat: nil, direction: .inbound, status: .failed)
//
//                ]
//        )
//        PaymentsListItemView(viewModel: .init())
        PaymentsListItemView(
            payments: [
                .init(hash: .localizedName(of: .ascii), preimage: nil, secret: nil, amountMsat: nil, direction: .inbound, status: .succeeded),
                .init(hash: .localizedName(of: .ascii), preimage: nil, secret: nil, amountMsat: nil, direction: .inbound, status: .pending),
                .init(hash: .localizedName(of: .ascii), preimage: nil, secret: nil, amountMsat: nil, direction: .inbound, status: .failed)
            ],
            networkColor: .yellow
        )
        PaymentsListItemView(
            payments: [
                .init(hash: .localizedName(of: .ascii), preimage: nil, secret: nil, amountMsat: nil, direction: .inbound, status: .succeeded),
                .init(hash: .localizedName(of: .ascii), preimage: nil, secret: nil, amountMsat: nil, direction: .inbound, status: .pending),
                .init(hash: .localizedName(of: .ascii), preimage: nil, secret: nil, amountMsat: nil, direction: .inbound, status: .failed)
            ],
            networkColor: .yellow
        )
        .environment(\.colorScheme, .dark)
    }
}
