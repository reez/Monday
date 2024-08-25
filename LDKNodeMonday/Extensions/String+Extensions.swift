//
//  String+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 4/25/23.
//

import Foundation

extension String {

    func bolt11amount() -> String? {
        print("Entering bolt11amount() with input: \(self)")

        // Updated regex pattern to be more flexible
        let regex = try! NSRegularExpression(
            pattern: "ln(?:bc|tb|tbs)(?<amount>\\d+)(?<multiplier>[munp]?)",
            options: [.caseInsensitive]
        )
        print("Regex pattern: \(regex.pattern)")

        if let match = regex.firstMatch(
            in: self,
            options: [],
            range: NSRange(location: 0, length: self.utf16.count)
        ) {
            print("Regex match found")

            guard let amountRange = Range(match.range(withName: "amount"), in: self),
                let multiplierRange = Range(match.range(withName: "multiplier"), in: self)
            else {
                print("Failed to extract amount or multiplier ranges")
                return nil
            }

            let amountString = String(self[amountRange])
            let multiplierString = String(self[multiplierRange])

            print("Extracted amount: \(amountString), multiplier: \(multiplierString)")

            guard let amount = Int(amountString) else {
                print("Failed to convert amount to Int")
                return nil
            }

            var conversion = Double(amount)
            print("Initial conversion: \(conversion)")

            switch multiplierString.lowercased() {
            case "m":
                conversion *= 0.001
                print("Applied 'm' multiplier")
            case "u":
                conversion *= 0.000001
                print("Applied 'u' multiplier")
            case "n":
                conversion *= 0.000000001
                print("Applied 'n' multiplier")
            case "p":
                conversion *= 0.000000000001
                print("Applied 'p' multiplier")
            default:
                print("No multiplier applied")
            }

            let convertedAmount = conversion * 100_000_000
            let formattedAmount = String(format: "%.0f", convertedAmount)
            print("Final converted amount: \(formattedAmount) satoshis")
            return formattedAmount
        } else {
            print("No regex match found")
        }

        print("Returning nil from bolt11amount()")
        return nil
    }

    func formattedAmount() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSize = 3

        if let number = Int(self),
            let formattedNumber = formatter.string(from: NSNumber(value: number))
        {
            return formattedNumber
        } else {
            return ""
        }
    }

    func formattedAmountZero() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSize = 3

        if let number = Int(self),
            let formattedNumber = formatter.string(from: NSNumber(value: number))
        {
            return formattedNumber
        } else {
            return "0"
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

    private var isLightningAddress: Bool {
        let lowercasedSelf = self.lowercased()
        let queryParams = self.queryParameters()
        if let lightningParam = queryParams["lightning"], !lightningParam.isEmpty {
            return true
        }
        return lowercasedSelf.starts(with: "ln") || lowercasedSelf.hasPrefix("lightning:")
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

    private func queryParameters() -> [String: String] {
        guard let range = self.range(of: "?") else { return [:] }
        let queryString = self[range.upperBound...]

        var params: [String: String] = [:]
        queryString.split(separator: "&").forEach {
            let pair = $0.split(separator: "=")
            if pair.count == 2 {
                params[String(pair[0])] = String(pair[1])
            }
        }

        return params
    }

    func processBIP21(_ input: String, spendableBalance: UInt64) -> (String, String, Payment) {
        print("Processing BIP21 URI")
        guard let url = URL(string: input),
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            print("Failed to parse BIP21 URI")
            return ("", "0", .isNone)
        }

        let bitcoinAddress = url.path
        var amount = "0"
        var bolt12Offer: String?
        var bolt11Invoice: String?

        for item in components.queryItems ?? [] {
            switch item.name.lowercased() {
            case "amount":
                if let value = item.value, let btcAmount = Double(value) {
                    amount = String(format: "%.0f", btcAmount * 100_000_000)  // Convert BTC to satoshis
                }
            case "lightning":
                bolt11Invoice = item.value
            case "lno":
                bolt12Offer = item.value
            default:
                break
            }
        }

        // Priority: Bolt 12 > Bolt 11 > On-chain
        if let offer = bolt12Offer {
            print("Bolt 12 offer found in BIP21 URI")
            return processLightningAddress(offer)
        }

        if let invoice = bolt11Invoice {
            print("Bolt 11 invoice found in BIP21 URI")
            return processLightningAddress(invoice)
        }

        print("Using on-chain Bitcoin address from BIP21 URI")
        return (bitcoinAddress, amount, .isBitcoin)
    }

    func extractPaymentInfo(spendableBalance: UInt64) -> (
        address: String, amount: String, payment: Payment
    ) {
        // BIP 21
        if self.lowercased().starts(with: "bitcoin:") && self.contains("?") {
            return processBIP21(self, spendableBalance: spendableBalance)
        }

        // Bolt 11 JIT
        // Check for BOLT11 invoice, including those prefixed with "lightning:"
        if self.lowercased().starts(with: "lightning:") {
            let invoice = String(self.dropFirst(10))  // Remove "lightning:" prefix
            return processLightningAddress(invoice)
        } else if self.lowercased().starts(with: "lnbc") || self.lowercased().starts(with: "lntb") {
            return processLightningAddress(self)
        }

        //        let queryParams = self.queryParameters()
        //
        //        if let lightningAddress = queryParams["lightning"], !lightningAddress.isEmpty {
        //            return processLightningAddress(lightningAddress)
        //        }
        else if self.isBitcoinAddress {
            return processBitcoinAddress(spendableBalance)
        } else if self.starts(with: "lnurl") {
            return ("LNURL not supported yet", "0", .isLightningURL)
        } else {
            return ("", "0", .isNone)
        }
    }

    private func processBitcoinAddress(_ spendableBalance: UInt64) -> (String, String, Payment) {
        let address = self.extractBitcoinAddress()
        let queryParams = self.queryParameters()
        let amount = queryParams["amount"] ?? "0"

        // Validate the amount against the spendable balance
        if let amountValue = UInt64(amount), amountValue <= spendableBalance {
            return (address, amount, .isBitcoin)
        } else {
            return (address, "0", .isBitcoin)
        }
    }

    private func processLightningAddress(_ address: String) -> (String, String, Payment) {
        let sanitizedAddress = address.replacingOccurrences(of: "lightning:", with: "")

        if sanitizedAddress.lowercased().starts(with: "lno") {
            return (sanitizedAddress, "0", .isLightning)
        } else {
            let amount = sanitizedAddress.bolt11amount() ?? "0"
            return (sanitizedAddress, amount, .isLightning)
        }
    }

    private func extractBitcoinAddress() -> String {
        if self.lowercased().hasPrefix("bitcoin:") {
            // Extract the address from the "bitcoin:" URI, ignoring any query parameters
            let address = self.replacingOccurrences(of: "bitcoin:", with: "")
            if let addressEnd = address.range(of: "?")?.lowerBound {  // New: Handles query parameters in BIP21
                return String(address[..<addressEnd]).uppercased()
            }
            return address.uppercased()
        }
        return self.uppercased()
    }

}
