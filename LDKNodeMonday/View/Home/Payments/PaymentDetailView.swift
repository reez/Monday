//
//  PaymentDetailView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 7/26/24.
//

import LDKNode
import SwiftUI

struct PaymentDetailView: View {
    let payment: PaymentDetails
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            VStack(alignment: .leading, spacing: 12) {

                HStack {
                    Spacer()
                    Image(
                        systemName: payment.isChainPayment
                            ? "bitcoinsign.circle" : "bolt.circle"
                    )
                    .foregroundColor(.primary)
                    .font(.largeTitle)
                    Spacer()
                }
                .padding()

                Group {
                    if let amountMsat = payment.amountMsat {
                        Divider()
                        DetailRowView(
                            label: "Amount",
                            value: "\(amountMsat.mSatsAsSats.formatted()) sats"
                        )
                    }
                    Divider()
                    DetailRowView(label: "Status", value: payment.title)
                    Divider()
                    DetailRowView(label: "Payment Type", value: payment.paymentKindString)
                    Divider()
                    DetailRowView(label: "Date", value: payment.formattedDate)
                }
                .padding(.horizontal)
                .padding(.vertical, 4)

            }
            .padding(.top)

        }
    }
}

struct DetailRowView: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
    }
}

#if DEBUG
    struct PaymentDetailView_Previews: PreviewProvider {
        static var previews: some View {
            PaymentDetailView(payment: mockPayments.first!)
        }
    }
#endif
