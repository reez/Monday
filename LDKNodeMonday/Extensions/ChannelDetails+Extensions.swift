//
//  ChannelDetails+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 12/13/23.
//

import Foundation
import LDKNode

extension ChannelDetails {
    func formatted() -> [ChannelDetailsFormatted] {
        let mirror = Mirror(reflecting: self)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

        let copyableProperties = ["channelId", "counterpartyNodeId", "fundingTxo"]

        return mirror.children.compactMap { child in
            guard let label = child.label else { return nil }

            if child.value is ChannelConfig {
                return nil
            }

            let formattedLabel = label.formattedPropertyName()

            let valueString: String
            if let outPoint = child.value as? OutPoint {
                valueString = outPoint.txid.description
            } else if let optionalValue = child.value as? AnyOptional, optionalValue.isNil {
                valueString = "N/A"
            } else if let boolValue = child.value as? Bool {
                valueString = boolValue ? "true" : "false"
            } else if let msatValue = child.value as? UInt64, label.hasSuffix("Msat") {
                valueString = msatValue.mSatsAsSats.formatted(.number.notation(.automatic))
            } else if let msatValue = child.value as? UInt32, label.hasSuffix("Msat") {
                valueString = msatValue.formattedAmount()
            } else if let numberValue = child.value as? NSNumber {
                valueString = numberFormatter.string(from: numberValue) ?? "\(child.value)"
            } else {
                valueString = "\(child.value)"
            }

            let isCopyable = copyableProperties.contains(label)

            return ChannelDetailsFormatted(
                name: formattedLabel,
                value: valueString,
                isCopyable: isCopyable
            )
        }
    }
}

extension ChannelDetails {
    public static func == (lhs: ChannelDetails, rhs: ChannelDetails) -> Bool {
        return lhs.channelId == rhs.channelId
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(channelId)
    }
}
