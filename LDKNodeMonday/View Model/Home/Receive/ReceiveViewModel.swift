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
    @Published var receiveViewError: MondayError?
    @Published var networkColor = Color.gray
    @Published var amountSat: UInt64 = 12100

    let lightningClient: LightningNodeClient

    init(lightningClient: LightningNodeClient) {
        self.lightningClient = lightningClient
    }

    func receivePayment(amountSat: UInt64, message: String, expirySecs: UInt32) async {
        do {
            let unified = try await lightningClient.receive(
                amountSat,
                message,
                expirySecs
            )
            let parsedAddresses = parseUnifiedQR(unified)

            // IF amountSat is higher than existing channel(s) receive capacity, generate JIT invoice
            let maxReceiveCapacity = maxReceiveCapacity()
            if maxReceiveCapacity > amountSat.satsAsMsats {
                let jitInvoice = try await lightningClient.receiveViaJitChannel(
                    amountSat.satsAsMsats,
                    message,
                    expirySecs,
                    nil
                )
                let jitPaymentAddress = PaymentAddress(
                    type: .bolt11,
                    address: jitInvoice
                )

                var filteredAddresses =
                    parsedAddresses
                    .compactMap { $0 }
                    .filter { $0.type != .bolt11 }

                filteredAddresses.append(jitPaymentAddress)

                await MainActor.run {
                    self.paymentAddresses = filteredAddresses
                }

            } else {
                await MainActor.run {
                    self.paymentAddresses = parsedAddresses
                }
            }

        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            await MainActor.run {
                self.receiveViewError = .init(title: errorString.title, detail: errorString.detail)
            }
        } catch {
            await MainActor.run {
                self.receiveViewError = .init(
                    title: "Unexpected error",
                    detail: error.localizedDescription
                )
            }
        }
    }

    func generateUnifiedQR() async {
        let amountSat = UInt64(amountSat)
        await receivePayment(
            amountSat: amountSat,
            message: "Monday Wallet",
            expirySecs: UInt32(3600)
        )
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
            if param.starts(with: "lightning=") {
                bolt11 = String(param.dropFirst("lightning=".count))
            } else if param.starts(with: "lno=") {
                bolt12 = String(param.dropFirst("lno=".count))
            }
        }

        if bolt11 == nil && bolt12 == nil {
            return []
        }

        let paymentAddresses: [PaymentAddress?] = [
            PaymentAddress(
                type: .bip21,
                address: unifiedQR
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
        case .bolt11, .bolt12:
            return "lightning:"
        }
    }
    
    var description: String {
        switch self.type {
        case .bip21:
            return "Onchain & Lightning"
        case .onchain:
            return "Onchain"
        case .bolt11:
            return "Lightning - Bolt11"
        case .bolt12:
            return "Lightning - Bolt12"
        }
    }
}

extension PaymentAddress {
    var qrString: String {
        return self.prefix + address
    }
}
