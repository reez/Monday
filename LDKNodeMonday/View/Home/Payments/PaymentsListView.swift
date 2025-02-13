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
    @Binding var transactions: [PaymentDetails]
    @Binding var displayBalanceType: DisplayBalanceType
    var price: Double

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
        Dictionary(grouping: transactions, by: { $0.status })
    }

    var body: some View {
        List {
            Section {
                if transactions.isEmpty {
                    VStack {
                        // Empty state
                        Image(systemName: "eyes")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)

                        Text("Nothing to see here, yet.\nGo get some bitcoin!")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 300)  // Ensure vertical space
                    .listRowSeparator(.hidden)
                } else {
                    // List transactions
                    ForEach(transactions, id: \.id) { payment in
                        TransactionItemView(
                            transaction: payment,
                            displayBalanceType: displayBalanceType,
                            price: price
                        )
                        .padding(.vertical, 5)
                        .listRowSeparator(.hidden)
                    }
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
    var price: Double

    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.bitcoinNeutral2)
                    .frame(width: 40, height: 40)
                Image(systemName: transaction.iconName)
                    .font(.system(.body, weight: .bold))
                    .foregroundColor(.bitcoinNeutral8)
                Circle()
                    .fill(Color.white)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Image(systemName: transaction.kind == .onchain ? "bitcoinsign" : "bolt")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundColor(.secondary)
                    )
                    .offset(x: 20, y: 11)
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
                Text(
                    transaction.primaryAmount(displayBalanceType: displayBalanceType, price: price)
                )
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundColor(transaction.amountColor)
                Text(
                    transaction.secondaryAmount(
                        displayBalanceType: displayBalanceType,
                        price: price
                    )
                )
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

        switch minutesSince {
        case ..<1:
            return "Just now"

        case ..<2:
            return "1 minute ago"

        case ..<60:
            return "\(Int(minutesSince)) minutes ago"

        default:
            if calendar.isDate(date, inSameDayAs: now) {
                return "Today at \(date.formatted(date: .omitted, time: .shortened))"
            }

            let dateFormat: Date.FormatStyle =
                calendar.component(.year, from: date) == calendar.component(.year, from: now)
                ? .dateTime.month(.abbreviated).day()
                : .dateTime.month(.abbreviated).day().year()

            return date.formatted(dateFormat)
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

    public func primaryAmount(displayBalanceType: DisplayBalanceType, price: Double) -> String {
        let mSatsAmount = self.amountMsat ?? 0
        let satsAmount = mSatsAmount.mSatsAsSats
        let symbol = self.direction == .inbound ? "+ " : "- "

        let formattedValue: String = {
            switch displayBalanceType {
            case .fiatSats, .fiatBtc:
                return satsAmount.formattedSatsAsUSD(price: price)
            case .btcFiat:
                return satsAmount.formattedSatsAsBtc()
            default:
                return satsAmount.formatted(.number.notation(.automatic))
            }
        }()

        return symbol + formattedValue
    }

    public func secondaryAmount(displayBalanceType: DisplayBalanceType, price: Double) -> String {
        let mSatsAmount = self.amountMsat ?? 0
        let satsAmount = mSatsAmount.mSatsAsSats

        let formattedValue: String = {
            switch displayBalanceType {
            case .fiatSats:
                return satsAmount.formatted(.number.notation(.automatic))
            case .fiatBtc:
                return satsAmount.formattedSatsAsBtc()
            default:
                return satsAmount.formattedSatsAsUSD(price: price)
            }
        }()

        return formattedValue
    }
}

#if DEBUG
    #Preview {
        PaymentsListView(
            transactions: .constant([]),
            displayBalanceType: .constant(.fiatSats),
            price: 75000.14
        )
    }
#endif
