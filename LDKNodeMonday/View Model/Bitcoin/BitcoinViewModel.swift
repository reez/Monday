//
//  BalanceViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import LDKNode
import SwiftUI

class BitcoinViewModel: ObservableObject {
    @Published var balance: String = "0"
    @Published var bitcoinViewError: MondayError?
    @Published var networkColor = Color.gray
    @Published var spendableBalance: String = "0"
    @Published var totalBalance: String = "0"
    @Published var isSpendableBalanceFinished: Bool = false
    @Published var isTotalBalanceFinished: Bool = false

    func getTotalOnchainBalanceSats() async {
        do {
            let balance = try await LightningNodeService.shared.getTotalOnchainBalanceSats()
            let stringIntBalance = balance.formattedSatoshis()
            DispatchQueue.main.async {
                self.totalBalance = stringIntBalance
                self.isTotalBalanceFinished = true
            }
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.bitcoinViewError = .init(title: errorString.title, detail: errorString.detail)
            }
        } catch {
            DispatchQueue.main.async {
                self.bitcoinViewError = .init(
                    title: "Unexpected error",
                    detail: error.localizedDescription
                )
            }
        }
    }

    func getSpendableOnchainBalanceSats() async {
        do {
            let balance = try await LightningNodeService.shared.getSpendableOnchainBalanceSats()
            let stringIntBalance = balance.formattedSatoshis()
            DispatchQueue.main.async {
                self.spendableBalance = stringIntBalance
                self.isSpendableBalanceFinished = true
            }
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.bitcoinViewError = .init(title: errorString.title, detail: errorString.detail)
            }
        } catch {
            DispatchQueue.main.async {
                self.bitcoinViewError = .init(
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
