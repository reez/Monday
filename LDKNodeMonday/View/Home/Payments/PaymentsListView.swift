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
                ForEach(payments, id: \.id) { payment in
                    TransactionItemView(
                        transaction: payment,
                        displayBalanceType: displayBalanceType
                    )
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
    var displayBalanceType: DisplayBalanceType

    var body: some View {
        HStack(spacing: 15) {
            let date = Date(timeIntervalSince1970: TimeInterval(transaction.latestUpdateTimestamp))
            ZStack {
                Circle()
                    .fill(Color.bitcoinNeutral1)
                    .frame(width: 40, height: 40)
                Image(systemName: transaction.iconName)
                    .font(.system(.subheadline, weight: .bold))
                    .foregroundColor(.bitcoinNeutral8)
            }
            VStack(alignment: .leading) {
                Text(transaction.title)
                    .font(.system(.body, design: .rounded, weight: .medium))
                Text(date.formatted(date: .abbreviated, time: .standard))
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(transaction.primaryAmount(displayBalanceType: displayBalanceType))
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundColor(transaction.amountColor)
                Text(transaction.secondaryAmount(displayBalanceType: displayBalanceType))
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(transaction.secondaryAmountColor)
            }
        }
    }
}

extension PaymentDetails {
    public var iconName: String {
        switch self.status {
        case .succeeded:
            return self.direction == .inbound ? "arrow.down" : "arrow.up"
        case .pending:
            return "clock"
        case .failed:
            return "x.circle"
        }
    }

    public var title: String {
        switch self.status {
        case .succeeded:
            return self.direction == .inbound ? "Received" : "Sent"
        case .pending:
            return "Pending"
        case .failed:
            return "Failed"
        }
    }

    public var amountColor: Color {
        switch self.status {
        case .succeeded:
            return self.direction == .inbound ? .bitcoinGreen : .bitcoinNeutral8
        case .pending:
            return .bitcoinNeutral4
        case .failed:
            return .bitcoinNeutral4
        }
    }

    public var secondaryAmountColor: Color {
        switch self.status {
        case .succeeded:
            return .secondary
        case .pending:
            return .bitcoinNeutral4
        case .failed:
            return .bitcoinNeutral4
        }
    }

    public func primaryAmount(displayBalanceType: DisplayBalanceType) -> String {
        let paymentAmount = self.amountMsat ?? 0
        let satsAmount = paymentAmount.formattedAmount()
        let fiatAmount = Double(paymentAmount / 1000).valueInUSD(price: 26030)  // TODO: expose price here
        switch self.status {
        default:
            return (self.direction == .inbound ? "+ " : "- ")
                + (displayBalanceType == .fiatSats ? fiatAmount : satsAmount)
        }
    }

    public func secondaryAmount(displayBalanceType: DisplayBalanceType) -> String {
        let paymentAmount = self.amountMsat ?? 0
        let satsAmount = paymentAmount.formattedAmount()
        let fiatAmount = Double(paymentAmount / 1000).valueInUSD(price: 26030)  // TODO: expose price here
        switch self.status {
        default:
            return displayBalanceType == .fiatSats ? satsAmount : fiatAmount
        }
    }
}

#if DEBUG
    #Preview {
        PaymentsListView(
            payments: .constant(mockPayments),
            displayBalanceType: .constant(.fiatSats)
        )
    }
#endif
