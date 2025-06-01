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
    @Published var paymentSendState: PaymentSendState = .pending
    private var sentPaymentId: String?

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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLdkEvent(_:)),
            name: .ldkEventReceived,
            object: nil
        )
    }

    @objc private func handleLdkEvent(_ notification: Notification) {
        guard let event = notification.object as? Event else { return }
        guard let paymentId = sentPaymentId else { return }
        switch event {
        case .paymentSuccessful(_, let paymentHash, _, _):
            if paymentHash == paymentId {
                paymentSendState = .succeeded
            }
        case .paymentFailed(_, let paymentHash, _):
            if let hash = paymentHash, hash == paymentId {
                paymentSendState = .failed
            }
        default:
            break
        }
    }

    func send() async throws {
        do {
            var paymentId: String? = nil
            switch paymentAddress?.type {
            case .bip21:
                let uriString = paymentAddress?.address ?? ""
                let result = try await lightningClient.send(uriString)
                if let id = (result as? QrPaymentResult)?.id { paymentId = id }
            case .onchain:
                let uriString = unifiedQRString(
                    onchainAddress: paymentAddress?.address ?? "",
                    amountBTC: amountSat.satsAsBTC,
                    message: nil,
                    bolt11: nil,
                    bolt12: nil
                )
                let result = try await lightningClient.send(uriString)
                if let id = (result as? QrPaymentResult)?.id { paymentId = id }
            case .bolt11:
                let result = try await lightningClient.sendBolt11Payment(
                    Bolt11Invoice(paymentAddress?.address ?? ""),
                    nil
                )
                paymentId = result.value
            default:
                debugPrint("Unhandled paymentAddress type")
                DispatchQueue.main.async {
                    self.sendError = .init(
                        title: "Unsupported payment type",
                        detail: "The payment address type is not supported."
                    )
                }
            }
            if let paymentId = paymentId {
                self.sentPaymentId = paymentId
                self.paymentSendState = .pending
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
