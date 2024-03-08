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
@Observable
class AmountViewModel {
    var networkColor = Color.gray
    var amountConfirmationViewError: MondayError?

    func sendAllToOnchain(address: String) async {
        do {
            try await LightningNodeService.shared.sendAllToOnchainAddress(
                address: address
            )
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.amountConfirmationViewError = .init(
                    title: errorString.title,
                    detail: errorString.detail
                )
            }
        } catch {
            DispatchQueue.main.async {
                self.amountConfirmationViewError = .init(
                    title: "Unexpected error",
                    detail: error.localizedDescription
                )
            }
        }
    }

    func sendPayment(invoice: Bolt11Invoice) async {
        do {
            try await LightningNodeService.shared.sendPayment(invoice: invoice)
        } catch let error as NodeError {
            NotificationCenter.default.post(name: .ldkErrorReceived, object: error)

            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.amountConfirmationViewError = .init(
                    title: errorString.title,
                    detail: errorString.detail
                )
            }
        } catch {
            DispatchQueue.main.async {
                self.amountConfirmationViewError = .init(
                    title: "Unexpected error",
                    detail: error.localizedDescription
                )
            }
        }
    }

    func sendPaymentUsingAmount(invoice: Bolt11Invoice, amountMsat: UInt64) async {
        do {
            try await LightningNodeService.shared.sendPaymentUsingAmount(
                invoice: invoice,
                amountMsat: amountMsat
            )
        } catch let error as NodeError {
            NotificationCenter.default.post(name: .ldkErrorReceived, object: error)
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.amountConfirmationViewError = .init(
                    title: errorString.title,
                    detail: errorString.detail
                )
            }
        } catch {
            DispatchQueue.main.async {
                self.amountConfirmationViewError = .init(
                    title: "Unexpected error",
                    detail: error.localizedDescription
                )
            }
        }
    }

    func getColor() {
        let color = LightningNodeService.shared.networkColor
        DispatchQueue.main.async {
            self.networkColor = color
        }
    }
}
