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

    func send(uriStr: String) async throws -> QrPaymentResult {
        do {
            let qrPaymentResult = try await LightningNodeService.shared.send(uriStr: uriStr)
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

    func getColor() {
        let color = LightningNodeService.shared.networkColor
        DispatchQueue.main.async {
            self.networkColor = color
        }
    }

}
