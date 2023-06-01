//
//  ReceiveViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import SwiftUI
import LightningDevKitNode

class ReceiveViewModel: ObservableObject {
    @Published var amountMsat: String = ""
    @Published var invoice: PublicKey = ""
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
                self.receiveViewError = .init(title: "Unexpected error", detail: error.localizedDescription)
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
