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
    @Published var balances: BalanceDetails

    init(
        lightningClient: LightningNodeClient,
        sendViewState: SendViewState,
        price: Double,
        balances: BalanceDetails
    ) {
        self.lightningClient = lightningClient
        self.sendViewState = sendViewState
        self.price = price
        self.balances = balances
    }

    func send() async throws {
        do {
            switch paymentAddress?.type {
            case .bip21:
                let uriString = paymentAddress?.address ?? ""
                let result = try await lightningClient.send(uriString)
                if case .onchain = result {
                    try? lightningClient.syncWallets()
                }
            case .bolt12:
                let result = try await lightningClient.send(paymentAddress?.address ?? "")
                if case .onchain = result {
                    try? lightningClient.syncWallets()
                }
            case .onchain:
                let uriString = unifiedQRString(
                    onchainAddress: paymentAddress?.address ?? "",
                    amountBTC: amountSat.satsAsBTC,
                    message: nil,
                    bolt11: nil,
                    bolt12: nil
                )
                let result = try await lightningClient.send(uriString)
                if case .onchain = result {
                    try? lightningClient.syncWallets()
                }
            case .bolt11:
                _ = try await lightningClient.sendBolt11Payment(
                    Bolt11Invoice.fromStr(invoiceStr: paymentAddress?.address ?? ""),
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
