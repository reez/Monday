//
//  SendBitcoinViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 6/7/23.
//

import LDKNode
import SwiftUI

class SendBitcoinViewModel: ObservableObject {
    let spendableBalance: String
    @Published var address: String = ""
    @Published var txId: String = ""
    @Published var sendViewError: MondayError?
    @Published var networkColor = Color.gray
    @Published var isSendFinished: Bool = false

    init(spendableBalance: String) {
        self.spendableBalance = spendableBalance
    }

    func sendAllToOnchain(address: String) async {
        do {
            let txId = try await LightningNodeService.shared.sendAllToOnchain(address: address)
            DispatchQueue.main.async {
                self.txId = txId
                self.isSendFinished = true
            }
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.sendViewError = .init(title: errorString.title, detail: errorString.detail)
            }
        } catch {
            DispatchQueue.main.async {
                self.sendViewError = .init(
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
