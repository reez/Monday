//
//  Bolt12InvoiceViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 6/1/24.
//

import Foundation
import LDKNode
import SwiftUI

class Bolt12InvoiceViewModel: ObservableObject {
    @Published var invoice: Bolt12Invoice = ""
    @Published var receiveViewError: MondayError?
    @Published var networkColor = Color.gray
    @Published var amountMsat: String = ""

    func receivePayment(amountMsat: UInt64, description: String) async {
        do {
            let invoice = try await LightningNodeService.shared.receive(
                amountMsat: amountMsat,
                description: description
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
