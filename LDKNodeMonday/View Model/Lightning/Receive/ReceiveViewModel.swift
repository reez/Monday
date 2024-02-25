//
//  ReceiveViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import LDKNode
import SwiftUI

class ReceiveViewModel: ObservableObject {
    @Published var amountMsat: String = ""
    @Published var invoice: Bolt11Invoice = ""
    @Published var invoiceJIT: Bolt11Invoice = ""
    @Published var receiveViewError: MondayError?
    @Published var networkColor = Color.gray

    func receivePayment(amountMsat: UInt64, description: String, expirySecs: UInt32) async {
        do {
            let invoice = try await LightningNodeService.shared.receivePayment(
                amountMsat: amountMsat,
                description: description,
                expirySecs: expirySecs
            )
            DispatchQueue.main.async {
                self.invoice = invoice
            }
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.receiveViewError = .init(title: errorString.title, detail: errorString.detail)
            }
        } catch {
            DispatchQueue.main.async {
                self.receiveViewError = .init(
                    title: "Unexpected error",
                    detail: error.localizedDescription
                )
            }
        }
    }
    
    func receivePaymentViaJitChannel(amountMsat: UInt64, description: String, expirySecs: UInt32, maxLspFeeLimitMsat: UInt64?) async {
        do {
            let invoiceJIT = try await LightningNodeService.shared.receivePaymentViaJitChannel(
                amountMsat: amountMsat,
                description: description,
                expirySecs: expirySecs,
                maxLspFeeLimitMsat: maxLspFeeLimitMsat
            )
            print("invoiceJIT: \n \(invoiceJIT)")
            DispatchQueue.main.async {
                self.invoiceJIT = invoiceJIT
            }
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.receiveViewError = .init(title: errorString.title, detail: errorString.detail)
            }
        } catch {
            DispatchQueue.main.async {
                self.receiveViewError = .init(
                    title: "Unexpected error",
                    detail: error.localizedDescription
                )
            }
        }
    }

    func clearInvoice() {
        self.invoice = ""
    }

    func getColor() {
        let color = LightningNodeService.shared.networkColor
        DispatchQueue.main.async {
            self.networkColor = color
        }
    }

}
