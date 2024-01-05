//
//  BalanceViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import LDKNode
import SwiftUI

class BitcoinViewModel: ObservableObject {
    let priceClient: PriceClient

    @Published var bitcoinViewError: MondayError?
    @Published var networkColor = Color.gray
    @Published var spendableBalance: String = "0.00 000 000"
    @Published var totalBalance: UInt64 = 0
    @Published var isSpendableBalanceFinished: Bool = false
    @Published var isTotalBalanceFinished: Bool = false
    @Published var isPriceFinished: Bool = false

    var price: Double = 0.00
    var time: Int?
    var satsPrice: String {
        let usdValue = Double(totalBalance).valueInUSD(price: price)
        return usdValue
    }

    init(priceClient: PriceClient) {
        self.priceClient = priceClient
    }

    func getTotalOnchainBalanceSats() async {
        do {
            let balance = try await LightningNodeService.shared.totalOnchainBalanceSats()
            DispatchQueue.main.async {
                self.totalBalance = balance
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
            let balance = try await LightningNodeService.shared.spendableOnchainBalanceSats()
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

    func getPrices() async {
        do {
            let price = try await priceClient.fetchPrice()
            DispatchQueue.main.async {
                self.price = price.usd
                self.time = price.time
                self.isPriceFinished = true
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
