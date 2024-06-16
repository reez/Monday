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

    func sendToOnchain(address: String, amountMsat: UInt64) async {
        do {
            try await LightningNodeService.shared.sendToOnchainAddress(
                address: address,
                amountMsat: amountMsat
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

    func sendPaymentBolt12(invoice: Bolt12Invoice) async {
        do {
            try await LightningNodeService.shared.sendPaymentBolt12(invoice: invoice)
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

    func handleLightningPayment(address: String, numpadAmount: String) async {
        if address.starts(with: "lno") {
            await sendPaymentBolt12(invoice: address)
        } else if address.bolt11amount() == "0" {
            if let amountSats = UInt64(numpadAmount) {
                let amountMsat = amountSats * 1000
                await sendPaymentUsingAmount(invoice: address, amountMsat: amountMsat)
            } else {
                self.amountConfirmationViewError = .init(
                    title: "Unexpected error",
                    detail: "Invalid amount entered"
                )
            }
        } else {
            await sendPayment(invoice: address)
        }
    }

    func handleBitcoinPayment(address: String, numpadAmount: String) async {
        if numpadAmount == "0" {
            self.amountConfirmationViewError = .init(
                title: "Unexpected error",
                detail: "Invalid amount entered"
            )
        } else if let amount = UInt64(numpadAmount) {
            await sendToOnchain(address: address, amountMsat: amount)
        } else {
            self.amountConfirmationViewError = .init(
                title: "Unexpected error",
                detail: "Unknown error occurred"
            )
        }
    }

    func handleLightningURLPayment() {
        self.amountConfirmationViewError = .init(
            title: "LNURL Error",
            detail: "LNURL not supported yet"
        )
    }

}
