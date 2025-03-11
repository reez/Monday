//
//  String+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 4/25/23.
//

import Foundation

extension String {

    func bolt11amount() -> String? {
        let regex = try! NSRegularExpression(
            pattern: "ln(?:bc|tb|tbs)(?<amount>\\d+)(?<multiplier>[munp]?)",
            options: [.caseInsensitive]
        )

        if let match = regex.firstMatch(
            in: self,
            options: [],
            range: NSRange(location: 0, length: self.utf16.count)
        ) {

            guard let amountRange = Range(match.range(withName: "amount"), in: self),
                let multiplierRange = Range(match.range(withName: "multiplier"), in: self)
            else {
                return nil
            }

            let amountString = String(self[amountRange])
            let multiplierString = String(self[multiplierRange])

            guard let amount = Int(amountString) else {
                return nil
            }

            var conversion = Double(amount)
            switch multiplierString.lowercased() {
            case "m":
                conversion *= 0.001
            case "u":
                conversion *= 0.000001
            case "n":
                conversion *= 0.000000001
            case "p":
                conversion *= 0.000000000001
            default:
                break
            }

            let convertedAmount = conversion * 100_000_000
            let formattedAmount = String(format: "%.0f", convertedAmount)
            return formattedAmount
        }

        return nil
    }

    func formattedAmount(defaultValue: String = "") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSize = 3

        if let number = Int(self),
            let formattedNumber = formatter.string(from: NSNumber(value: number))
        {
            return formattedNumber
        } else {
            return defaultValue
        }
    }

    func parseConnectionInfo() -> Peer? {
        if let atIndex = self.firstIndex(of: "@") {
            let nodeID = String(self[..<atIndex])
            let address = String(self[self.index(after: atIndex)...])
            return Peer(nodeID: nodeID, address: address)
        } else {
            return nil
        }
    }

    func truncated(toLength maxLength: Int, trailing: String = "...") -> String {
        if self.count > maxLength {
            let indexStart = self.index(self.startIndex, offsetBy: maxLength / 2)
            let indexEnd = self.index(self.endIndex, offsetBy: -(maxLength / 2))
            return String(self[..<indexStart]) + trailing + String(self[indexEnd...])
        }
        return self
    }

    func formattedPropertyName() -> String {
        let updatedName = self.replacingOccurrences(
            of: "msat",
            with: " Sats",
            options: .caseInsensitive
        )

        let words = updatedName.reduce("") { partialResult, char in
            if char.isUppercase {
                return "\(partialResult) \(char)"
            } else {
                return partialResult + String(char)
            }
        }.split(separator: " ")

        return words.map { $0.capitalized }.joined(separator: " ")
    }

    private var isBitcoinAddress: Bool {
        return lowercased().hasPrefix("bitcoin:") || isValidBitcoinAddress
    }

    private var isValidBitcoinAddress: Bool {
        let patterns = [
            "^1[a-km-zA-HJ-NP-Z1-9]{25,34}$",  // P2PKH Mainnet
            "^[mn2][a-km-zA-HJ-NP-Z1-9]{33}$",  // P2PKH or P2SH Testnet
            "^bc1[qzp][a-z0-9]{38,}$",  // Bech32 Mainnet
            "^tb1[qzp][a-z0-9]{38,}$",  // Bech32 Testnet
        ]
        return patterns.contains {
            self.range(of: $0, options: [.regularExpression, .caseInsensitive]) != nil
        }
    }

    func queryParameters() -> [String: String] {
        guard let url = URL(string: self) else { return [:] }
        return url.queryParameters()
    }

    func processBIP21(_ input: String, spendableBalance: UInt64) -> (UInt64, PaymentAddress?) {
        guard let url = URL(string: input),
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            return (0, nil)
        }

        let bitcoinAddress = url.path
        var amount = "0"
        var bolt12Offer: String?
        var bolt11Invoice: String?

        for item in components.queryItems ?? [] {
            switch item.name.lowercased() {
            case "amount":
                if let value = item.value, let btcAmount = Double(value) {
                    amount = String(format: "%.0f", btcAmount * 100_000_000)
                }
            case "lightning":
                bolt11Invoice = item.value
            case "lno":
                bolt12Offer = item.value
            default:
                break
            }
        }

        if let offer = bolt12Offer {
            return processLightningAddress(offer, amount: amount)
        }
        if let invoice = bolt11Invoice {
            return processLightningAddress(invoice, amount: amount)
        }
        return (UInt64(amount) ?? 0, PaymentAddress(type: .onchain, address: bitcoinAddress))
    }

    func extractPaymentInfo(spendableBalance: UInt64) -> (
        amount: UInt64, payment: PaymentAddress?
    ) {
        if self.lowercased().starts(with: "bitcoin:") && self.contains("?") {
            return processBIP21(self, spendableBalance: spendableBalance)
        } else if self.lowercased().starts(with: "lightning:") {
            let invoice = String(self.dropFirst(10))  // Remove "lightning:" prefix
            return processLightningAddress(invoice, amount: "")
        } else if self.lowercased().starts(with: "lnbc") || self.lowercased().starts(with: "lntb") {
            return processLightningAddress(self, amount: "")
        } else if self.isBitcoinAddress {
            return processBitcoinAddress(spendableBalance)
        } else if self.starts(with: "lnurl") {
            return (0, nil)  // TODO: Implement support for lnurl
        } else {
            return (0, .none)
        }
    }

    private func processBitcoinAddress(_ spendableBalance: UInt64) -> (UInt64, PaymentAddress) {
        let address = self.extractBitcoinAddress()
        let queryParams = self.queryParameters()
        let amount = queryParams["amount"] ?? ""

        if let amountValue = UInt64(amount), amountValue <= spendableBalance {
            return (amountValue, PaymentAddress(type: .onchain, address: address))
        } else {
            return (0, PaymentAddress(type: .onchain, address: address))
        }
    }

    private func processLightningAddress(_ address: String, amount: String) -> (
        UInt64, PaymentAddress
    ) {
        let sanitizedAddress = address.replacingOccurrences(of: "lightning:", with: "")

        if sanitizedAddress.lowercased().starts(with: "lno") {
            // Use the amount passed from the BIP21 parsing logic
            return (UInt64(amount) ?? 0, PaymentAddress(type: .bolt12, address: sanitizedAddress))
        } else {
            let bolt11Amount = sanitizedAddress.bolt11amount() ?? amount
            return (UInt64(bolt11Amount) ?? 0, PaymentAddress(type: .bolt11, address: sanitizedAddress))
        }
    }

    private func extractBitcoinAddress() -> String {
        if self.lowercased().hasPrefix("bitcoin:") {
            let address = self.replacingOccurrences(of: "bitcoin:", with: "")
            if let addressEnd = address.range(of: "?")?.lowerBound {
                return String(address[..<addressEnd]).uppercased()
            }
            return address.uppercased()
        }
        return self.uppercased()
    }

}
