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
            case .onchain:
                let txId = try await lightningClient.sendToAddress(
                    paymentAddress?.address ?? "",
                    amountSat
                )
            default:
                let qrPaymentResult = try await lightningClient.send(paymentAddress?.address ?? "")
            }
        } catch let error as NodeError {
            NotificationCenter.default.post(name: .ldkErrorReceived, object: error)
            let errorString = handleNodeError(error)
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
