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
    var amountConfirmationViewError: MondayError?
    let lightningClient: LightningNodeClient
    @Published var paymentAddress: PaymentAddress?
    @Published var address = ""
    @Published var amountSat: UInt64 = 0

    init(lightningClient: LightningNodeClient) {
        self.lightningClient = lightningClient
    }

    func send(uriStr: String) async throws -> QrPaymentResult {
        do {
            let qrPaymentResult = try await lightningClient.send(uriStr)
            return qrPaymentResult
        } catch let error as NodeError {
            NotificationCenter.default.post(name: .ldkErrorReceived, object: error)
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.amountConfirmationViewError = .init(
                    title: errorString.title,
                    detail: errorString.detail
                )
            }
            throw error
        } catch {
            DispatchQueue.main.async {
                self.amountConfirmationViewError = .init(
                    title: "Unexpected error",
                    detail: error.localizedDescription
                )
            }
            throw error
        }
    }
}
