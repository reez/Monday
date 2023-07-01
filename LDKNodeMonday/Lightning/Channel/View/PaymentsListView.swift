//
//  PaymentsListView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 6/30/23.
//

import SwiftUI
import LDKNode

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
                .init(hash: .localizedName(of: .ascii), preimage: nil, secret: nil, amountMsat: nil, direction: .inbound, status: .succeeded),
                .init(hash: .localizedName(of: .ascii), preimage: nil, secret: nil, amountMsat: nil, direction: .inbound, status: .pending),
                .init(hash: .localizedName(of: .ascii), preimage: nil, secret: nil, amountMsat: nil, direction: .inbound, status: .failed)
            ]
        )
        PaymentsListView(
            payments: [
                .init(hash: .localizedName(of: .ascii), preimage: nil, secret: nil, amountMsat: nil, direction: .inbound, status: .succeeded),
                .init(hash: .localizedName(of: .ascii), preimage: nil, secret: nil, amountMsat: nil, direction: .inbound, status: .pending),
                .init(hash: .localizedName(of: .ascii), preimage: nil, secret: nil, amountMsat: nil, direction: .inbound, status: .failed)
            ]
        )
        .environment(\.colorScheme, .dark)
    }
}
