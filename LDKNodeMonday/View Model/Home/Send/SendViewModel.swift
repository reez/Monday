//
//  AmountViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/27/24.
//

import BitcoinUI
import Foundation
import LDKNode
import SwiftUI

@MainActor
class SendViewModel: ObservableObject {
    let lightningClient: LightningNodeClient
    @Published var sendViewState: SendViewState
    @Published var paymentAddress: PaymentAddress?
    @Published var address = ""
    @Published var amountSat: UInt64 = 0
    @Published var sendError: MondayError?
    var price: Double

    init(lightningClient: LightningNodeClient, sendViewState: SendViewState, price: Double) {
        self.lightningClient = lightningClient
        self.sendViewState = sendViewState
        self.price = price
    }

    func send() async throws {
        do {
            switch paymentAddress?.type {
            case .bip21:
                let uriString = paymentAddress?.address ?? ""
                _ = try await lightningClient.send(uriString)
            case .onchain:
                let uriString = unifiedQRString(
                    onchainAddress: paymentAddress?.address ?? "",
                    amountBTC: amountSat.satsAsBTC,
                    message: nil,
                    bolt11: nil,
                    bolt12: nil
                )
                _ = try await lightningClient.send(uriString)
            case .bolt11:
                _ = try await lightningClient.sendBolt11Payment(
                    Bolt11Invoice(paymentAddress?.address ?? ""),
                    nil
                )
            default:
                debugPrint("Unhandled paymentAddress type")
                DispatchQueue.main.async {
                    self.sendError = .init(
                        title: "Unsupported payment type",
                        detail: "The payment address type is not supported."
                    )
                }
            }
        } catch let error as NodeError {
            NotificationCenter.default.post(name: .ldkErrorReceived, object: error)
            let errorString = handleNodeError(error)
            debugPrint(errorString)
            DispatchQueue.main.async {
                self.sendError = .init(
                    title: errorString.title,
                    detail: errorString.detail
                )
            }
            throw error
        } catch {
            DispatchQueue.main.async {
                self.sendError = .init(
                    title: "Unexpected error",
                    detail: error.localizedDescription
                )
            }
            throw error
        }
    }
}
