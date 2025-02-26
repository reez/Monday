//
//  BIP21ViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 7/19/24.
//

import BitcoinUI
import Foundation
import LDKNode
import SwiftUI

class ReceiveViewModel: ObservableObject {
    @Published var selectedOption: ReceiveOption = .bip21
    @Published var paymentAddresses: [PaymentAddress?] = []
    @Published var addressGenerationFinished = false
    @Published var receiveViewError: MondayError?
    @Published var networkColor = Color.gray
    @Published var amountSat: UInt64 = 0
    @Published var message: String = ""
    @Published var expirySecs: UInt32 = 3600

    let lightningClient: LightningNodeClient

    init(lightningClient: LightningNodeClient) {
        self.lightningClient = lightningClient
    }

    func generateAddresses() async {
        await receivePayment(amountSat: amountSat, message: message, expirySecs: expirySecs)
    }

    func receivePayment(amountSat: UInt64, message: String, expirySecs: UInt32) async {
        do {
            let unified = try await lightningClient.receive(amountSat, message, expirySecs)
            let parsedAddresses = parseUnifiedQR(unified)

            await MainActor.run {
                self.paymentAddresses = parsedAddresses
                self.addressGenerationFinished = true
            }

        } catch let error {
            debugPrint("Error generating unified QR: ", error.localizedDescription)

            // Fall back to create separate addressinfo
            var unifiedPaymentAddress: PaymentAddress?
            var onchainPaymentAddress: PaymentAddress?
            var bolt11PaymentAddress: PaymentAddress?

            // Onchain
            do {
                let onchainAddress = try await lightningClient.newAddress()
                onchainPaymentAddress = PaymentAddress(
                    type: .onchain,
                    address: onchainAddress
                )
            } catch {
                debugPrint("Error generating onchain address:", error.localizedDescription)
            }

            // Bolt11
            do {
                // IF amountSat is higher than existing channel(s) receive capacity, generate JIT invoice
                let maxReceiveCapacity = maxReceiveCapacity()
                if amountSat.satsAsMsats > maxReceiveCapacity {
                    let jitInvoice = try await lightningClient.receiveViaJitChannel(
                        amountSat.satsAsMsats,
                        message,
                        expirySecs,
                        nil
                    )
                    bolt11PaymentAddress = PaymentAddress(
                        type: .bolt11Jit,
                        address: jitInvoice
                    )
                } else {
                    // generate bolt11
                }
            } catch {
                debugPrint("Error generating Bolt11:", error.localizedDescription)
            }

            // Unified
            if bolt11PaymentAddress != nil {
                let unifiedQRString = unifiedQRString(
                    onchainAddress: onchainPaymentAddress?.address ?? "",
                    amountBTC: amountSat.satsAsBTC,
                    message: message,
                    bolt11: bolt11PaymentAddress?.address,
                    bolt12: nil
                )
                unifiedPaymentAddress = PaymentAddress(
                    type: .bip21,
                    address: unifiedQRString
                )
            }

            let addresses = [unifiedPaymentAddress, onchainPaymentAddress, bolt11PaymentAddress]
                .compactMap { $0 }

            await MainActor.run {
                self.paymentAddresses = addresses
                self.addressGenerationFinished = true
            }

            if paymentAddresses.isEmpty {
                await MainActor.run {
                    self.receiveViewError = .init(
                        title: "Address error",
                        detail: "Failed to generate any addresses."
                    )
                }
            }
        }
    }

    func maxReceiveCapacity() -> UInt64 {
        var maxReceiveCapacity = UInt64(0)
        let channels = lightningClient.listChannels()
        for channel in channels {
            if channel.inboundCapacityMsat > maxReceiveCapacity {
                maxReceiveCapacity = channel.inboundCapacityMsat
            }
        }
        return maxReceiveCapacity
    }

    func parseUnifiedQR(_ unifiedQR: String) -> [PaymentAddress?] {
        // Split the string by '?'
        let components = unifiedQR.components(separatedBy: "?")

        guard components.count > 1 else { return [] }

        // Extract onchain (everything before the first '?') and remove the "BITCOIN:" prefix
        var onchain = components[0]
        if onchain.lowercased().hasPrefix("bitcoin:") {
            onchain = String(onchain.dropFirst(8))  // Remove "BITCOIN:"
        }

        // Join the rest of the components back together
        let remainingString = components.dropFirst().joined(separator: "?")

        // Split the remaining string by '&'
        let params = remainingString.components(separatedBy: "&")

        var bolt11: String?
        var bolt12: String?

        for param in params {
            if param.lowercased().starts(with: "lightning=lnbc") {
                bolt11 = String(param.dropFirst("lightning=".count))
            } else if param.lowercased().starts(with: "lightning=lntb") {
                bolt11 = String(param.dropFirst("lightning=".count))
            } else if param.lowercased().starts(with: "lightning=lno") {
                bolt12 = String(param.dropFirst("lightning=".count))
            } else if param.lowercased().starts(with: "lno=") {
                bolt12 = String(param.dropFirst("lno=".count))
            }
        }

        let unifiedQRString = unifiedQRString(
            onchainAddress: onchain,
            amountBTC: amountSat.satsAsBTC,
            message: message,
            bolt11: bolt11,
            bolt12: bolt12
        )

        let paymentAddresses: [PaymentAddress?] = [
            PaymentAddress(
                type: .bip21,
                address: unifiedQRString
            ),
            PaymentAddress(
                type: .onchain,
                address: onchain
            ),
            bolt11.map {
                PaymentAddress(
                    type: .bolt11,
                    address: $0
                )
            },
            bolt12.map {
                PaymentAddress(
                    type: .bolt12,
                    address: $0
                )
            },
        ]

        return paymentAddresses
    }
}

enum AddressType {
    case bip21
    case onchain
    case bolt11
    case bolt11Jit
    case bolt12
}

public struct PaymentAddress {
    let type: AddressType
    let address: String

    var prefix: String {
        switch self.type {
        case .bip21:
            return ""
        case .onchain:
            return "bitcoin:"
        case .bolt11, .bolt11Jit, .bolt12:
            return "lightning:"
        }
    }

    var description: String {
        switch self.type {
        case .bip21:
            return "Unified address"
        case .onchain:
            return "Onchain address"
        case .bolt11:
            return "Lightning Bolt11"
        case .bolt11Jit:
            return "Lightning Bolt11 JIT"
        case .bolt12:
            return "Lightning Bolt12"
        }
    }

    func addressesToDisplay(addresses: [PaymentAddress?]) -> [PaymentAddress] {
        return {
            if self.type == .bip21 {
                return
                    addresses
                    .compactMap { $0 }
                    .filter { $0.type != .bip21 }
            } else {
                return
                    addresses
                    .compactMap { $0 }
                    .filter { $0.type == self.type }
            }
        }()
    }
}

extension PaymentAddress {
    var qrString: String {
        return self.prefix + address
    }
}

func unifiedQRString(
    onchainAddress: String,
    amountBTC: Double?,
    message: String?,
    bolt11: String?,
    bolt12: String?
) -> String {
    var qrString = "bitcoin:\(onchainAddress)"

    var queryItems: [String] = []

    if let amount = amountBTC, amount > 0 {
        queryItems.append("amount=\(String(format: "%.8f", amount))")
    }

    if let message = message, !message.isEmpty {
        queryItems.append(
            "message=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        )
    }

    if let bolt11 = bolt11, !bolt11.isEmpty {
        queryItems.append("lightning=\(bolt11)")
    }

    if let bolt12 = bolt12, !bolt12.isEmpty {
        queryItems.append("lno=\(bolt12)")
    }

    if !queryItems.isEmpty {
        qrString += "?" + queryItems.joined(separator: "&")
    }

    return qrString
}
