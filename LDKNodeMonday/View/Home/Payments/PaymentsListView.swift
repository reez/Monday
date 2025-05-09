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
    @Binding var payments: [PaymentDetails]
    @Binding var displayBalanceType: DisplayBalanceType
    var price: Double
    @State private var selectedPayment: PaymentDetails?

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

    var groupedPayments: [PaymentStatus: [PaymentDetails]] {
        Dictionary(grouping: payments, by: { $0.status })
    }

    var body: some View {
        List {
            Section {
                if payments.isEmpty {
                    Text("No activity, yet.\nGo get some bitcoin!")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 400)  // Ensure vertical space
                        .listRowSeparator(.hidden)
                } else {
                    // List payments
                    // Filter out: .pending that are older than 30 minutes or 0 amount
                    ForEach(
                        payments
                            .filter {
                                $0.status != .pending
                                    || ($0.status == .pending
                                        && Double($0.latestUpdateTimestamp) > Date()
                                            .timeIntervalSince1970 - 1800
                                        && ($0.amountMsat ?? 0) > 0)
                            }
                            .sorted { $0.latestUpdateTimestamp > $1.latestUpdateTimestamp },
                        id: \.id
                    ) { payment in
                        PaymentItemView(
                            payment: payment,
                            displayBalanceType: displayBalanceType,
                            price: price
                        )
                        .padding(.vertical, 5)
                        .listRowSeparator(.hidden)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.selectedPayment = payment
                        }
                    }
                }
            }
            /*
            header: {
                Text("Activity")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            */
        }
        .listStyle(.plain)
        .padding(.horizontal)
        .sheet(item: $selectedPayment) { paymentDetail in
            PaymentDetailView(
                payment: paymentDetail,
                displayBalanceType: displayBalanceType,
                price: price
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.hidden)
        }
    }
}

struct PaymentItemView: View {
    var payment: PaymentDetails
    var displayBalanceType: DisplayBalanceType
    var price: Double

    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.bitcoinNeutral2)
                    .frame(width: 40, height: 40)
                Image(systemName: payment.iconName)
                    .font(.system(.body, weight: .bold))
                    .foregroundColor(.bitcoinNeutral8)
                Circle()
                    .fill(.background)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Image(
                            systemName: payment.isChainPayment
                                ? "bitcoinsign" : "bolt"
                        )
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.secondary)
                    )
                    .offset(x: 20, y: 11)
            }
            VStack(alignment: .leading) {
                Text(payment.title)
                    .font(.system(.body, design: .rounded, weight: .medium))
                Text(payment.formattedDate)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(
                    payment.primaryAmount(displayBalanceType: displayBalanceType, price: price)
                )
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundColor(payment.amountColor)
                Text(
                    payment.secondaryAmount(
                        displayBalanceType: displayBalanceType,
                        price: price
                    )
                )
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(payment.secondaryAmountColor)
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.75)
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)  // Sets max dynamic size for all Text
    }
}

#if DEBUG
    #Preview {
        PaymentsListView(
            payments: .constant(mockPayments),
            displayBalanceType: .constant(.fiatSats),
            price: 75000.14
        )
    }
#endif
