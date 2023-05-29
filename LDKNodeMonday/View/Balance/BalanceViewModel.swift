//
//  BalanceViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import SwiftUI
import LightningDevKitNode
import WalletUI

class BalanceViewModel: ObservableObject {
    @Published var balance: String = "0"
    @Published var errorMessage: MondayNodeError?
    @Published var networkColor = Color.gray
    @Published var spendableBalance: String = "0"
    @Published var totalBalance: String = "0"
    @Published var isSpendableBalanceFinished: Bool = false
    @Published var isTotalBalanceFinished: Bool = false

    
    func getTotalOnchainBalanceSats() async {
        do {
            let balance = try await LightningNodeService.shared.getTotalOnchainBalanceSats()
            let intBalance = Int(balance)
            let stringIntBalance = String(intBalance)
            DispatchQueue.main.async {
                self.totalBalance = stringIntBalance
                self.isTotalBalanceFinished = true
            }
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.errorMessage = .init(title: errorString.title, detail: errorString.detail)
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = .init(title: "Unexpected error", detail: error.localizedDescription)
            }
        }
    }
    
    func getSpendableOnchainBalanceSats() async {
        do {
            let balance = try await LightningNodeService.shared.getSpendableOnchainBalanceSats()
            let intBalance = Int(balance)
            let stringIntBalance = String(intBalance)
            DispatchQueue.main.async {
                self.spendableBalance = stringIntBalance
                self.isSpendableBalanceFinished = true
            }
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.errorMessage = .init(title: errorString.title, detail: errorString.detail)
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = .init(title: "Unexpected error", detail: error.localizedDescription)
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
