//
//  BIP21ViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 7/19/24.
//

import BitcoinUI
import Foundation
import LDKNode
import SwiftUI

class BIP21ViewModel: ObservableObject {
    @Published var unified: String = ""
    @Published var receiveViewError: MondayError?
    @Published var networkColor = Color.gray
    @Published var amountSat: String = "0"

    private let lightningClient: LightningNodeClient

    init(lightningClient: LightningNodeClient) {
        self.lightningClient = lightningClient
    }

    func receivePayment(amountSat: UInt64, message: String, expirySecs: UInt32) async {
        do {
            let unified = try await lightningClient.receive(
                amountSat,
                message,
                expirySecs
            )

            DispatchQueue.main.async {
                self.unified = unified
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
