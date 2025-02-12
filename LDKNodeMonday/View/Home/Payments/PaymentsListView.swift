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
            ZStack {
                Circle()
                    .fill(Color.bitcoinNeutral2)
                    .frame(width: 40, height: 40)
                Image(systemName: transaction.iconName)
                    .font(.system(.subheadline, weight: .bold))
                    .foregroundColor(.bitcoinNeutral8)
            }
            VStack(alignment: .leading) {
                Text(transaction.title)
                    .font(.system(.body, design: .rounded, weight: .medium))
                Text(transaction.formattedDate)
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
        .lineLimit(1)
        .minimumScaleFactor(0.75)
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)  // Sets max dynamic size for all Text
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

    public var formattedDate: String {
        let calendar = Calendar.current
        let now = Date.now
        let date = Date(timeIntervalSince1970: TimeInterval(self.latestUpdateTimestamp))
        let minutesSince = abs(date.timeIntervalSince(now)) / 60

        // Just now
        if minutesSince <= 1 {
            return "Just now"
        }

        // X minutes ago
        if minutesSince < 60 {
            if #available(iOS 18.0, *) {
                // This should work better localized
                let attributedString = date.formatted(
                    .reference(
                        to: now,
                        allowedFields: [.minute],
                        maxFieldCount: 1,
                        thresholdField: .minute
                    )
                )
                return String(attributedString.characters)
            } else {
                return "\(Int(minutesSince)) minutes ago"
            }
        }

        // Today, at 1.15pm
        if calendar.isDate(date, inSameDayAs: now) {
            return "Today, \(date.formatted(date: .omitted, time: .shortened))"
        }

        // Jun 24, at 1.15pm
        if calendar.component(.year, from: date) == calendar.component(.year, from: now) {
            return
                "\(date.formatted(.dateTime.month().day())), \(date.formatted(date: .omitted, time: .shortened))"
        }

        // Jun 24, 2024 at 1.15pm
        return
            "\(date.formatted(.dateTime.month().day().year())), \(date.formatted(date: .omitted, time: .shortened))"
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
