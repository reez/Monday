//
//  PaymentDetails+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/6/25.
//

import Foundation
import LDKNode
import SwiftUI

extension PaymentDetails: Identifiable {}

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
                return "₿" + satsAmount.formattedSatsAsBtc()
            case .onchainBip177, .lightningBip177, .totalBip177:
                return "₿" + satsAmount.formattedBip177()
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

    public var isChainPayment: Bool {
        if case .onchain = self.kind {
            return true
        }
        return false
    }

    var paymentKindString: String {
        switch self.kind {
        case .onchain:
            return "Onchain"
        default:
            return "Lightning"
        }
    }

}
