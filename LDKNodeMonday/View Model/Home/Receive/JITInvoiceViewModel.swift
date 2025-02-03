//
//  JITInvoiceViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 3/4/24.
//

import BitcoinUI
import Foundation
import LDKNode
import SwiftUI

class JITInvoiceViewModel: ObservableObject {
    @Published var invoice: Bolt11Invoice = ""
    @Published var receiveViewError: MondayError?
    @Published var networkColor = Color.gray
    @Published var amountMsat: String = "121000"

    private let lightningClient: LightningNodeClient

    init(lightningClient: LightningNodeClient) {
        self.lightningClient = lightningClient
    }

    func receivePaymentViaJitChannel(
        amountMsat: UInt64,
        description: Bolt11InvoiceDescription,
        expirySecs: UInt32,
        maxLspFeeLimitMsat: UInt64?
    ) async {
        do {
            let invoice = try await lightningClient.receiveViaJitChannel(
                amountMsat,
                description,
                expirySecs,
                maxLspFeeLimitMsat
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

    func getColor() {
        let color = lightningClient.getNetworkColor()
        DispatchQueue.main.async {
            self.networkColor = color
        }
    }
}
