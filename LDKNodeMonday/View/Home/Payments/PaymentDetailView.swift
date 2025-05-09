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
    let displayBalanceType: DisplayBalanceType
    let price: Double
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text("Transaction Detail").bold()
                .padding()
                .padding(.bottom, 20)

            VStack(alignment: .leading, spacing: 12) {

                Group {
                    if let amountMsat = payment.amountMsat, amountMsat > 0 {
                        Divider()
                        DetailRowView(
                            label: "Amount",
                            primaryValue: payment.primaryAmount(
                                displayBalanceType: displayBalanceType,
                                price: price
                            ),
                            secondaryValue: payment.secondaryAmount(
                                displayBalanceType: displayBalanceType,
                                price: price
                            ),
                            primaryColor: payment.amountColor,
                            secondaryColor: payment.secondaryAmountColor
                        )
                    }
                    Divider()
                    DetailRowView(label: "Status", value: payment.title)
                    Divider()
                    DetailRowView(
                        label: "Payment Type",
                        value: payment.paymentKindString,
                        systemImageName: payment.isChainPayment
                            ? "bitcoinsign.circle" : "bolt.circle"
                    )
                    Divider()
                    DetailRowView(label: "Date", value: payment.formattedDate)
                }
                .padding(.horizontal)
                .padding(.vertical, 4)

            }

        }
    }
}

struct DetailRowView: View {
    let label: String
    var value: String? = nil
    var systemImageName: String? = nil
    var primaryValue: String? = nil
    var secondaryValue: String? = nil
    var primaryColor: Color? = .primary
    var secondaryColor: Color? = .secondary

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.primary)
            Spacer()
            if let systemImageName = systemImageName, let value = value {
                Image(systemName: systemImageName)
                    .foregroundColor(.secondary)
                Text(value)
                    .foregroundColor(.secondary)
            } else if let primaryValue = primaryValue, let secondaryValue = secondaryValue {
                VStack(alignment: .trailing) {
                    Text(primaryValue)
                        .foregroundColor(primaryColor)
                    Text(secondaryValue)
                        .font(.caption)
                        .foregroundColor(secondaryColor)
                }
            } else if let value = value {
                Text(value)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#if DEBUG
    struct PaymentDetailView_Previews: PreviewProvider {
        static var previews: some View {
            PaymentDetailView(
                payment: mockPayments.first!,
                displayBalanceType: .fiatSats,
                price: 70000.0
            )
        }
    }
#endif
