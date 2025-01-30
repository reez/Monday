//
//  BalanceViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import LDKNode
import SwiftUI

class BitcoinViewModel: ObservableObject {
    @Binding var walletClient: WalletClient
    @Published var bitcoinViewError: MondayError?
    @Published var networkColor = Color.gray
    @Published var status: NodeStatus?
    @Published var isStatusFinished: Bool = false
    @Published var spendableBalance: UInt64 = 0
    @Published var totalBalance: UInt64 = 0
    @Published var totalLightningBalance: UInt64 = 0
    @Published var lightningBalances: [LightningBalance] = []
    @Published var isSpendableBalanceFinished: Bool = false
    @Published var isTotalBalanceFinished: Bool = false
    @Published var isTotalLightningBalanceFinished: Bool = false
    @Published var isPriceFinished: Bool = false

    let lightningClient: LightningNodeClient
    let priceClient: PriceClient
    var price: Double = 0.00
    var time: Int?

    var satsPrice: String {
        let usdValue = Double(totalBalance).valueInUSD(price: price)
        return usdValue
    }

    var totalUSDValue: String {
        let totalUSD = Double(totalBalance + totalLightningBalance).valueInUSD(price: price)
        return totalUSD
    }

    init(
        walletClient: Binding<WalletClient>,
        priceClient: PriceClient,
        lightningClient: LightningNodeClient
    ) {
        _walletClient = walletClient
        self.priceClient = priceClient
        self.lightningClient = lightningClient
    }

    func getStatus() async {
        let status = lightningClient.status()
        DispatchQueue.main.async {
            self.status = status
            self.isStatusFinished = true
        }
    }

    func getTotalOnchainBalanceSats() async {
        let balance = await lightningClient.totalOnchainBalanceSats()
        DispatchQueue.main.async {
            self.totalBalance = balance
            self.isTotalBalanceFinished = true
        }
    }

    func getSpendableOnchainBalanceSats() async {
        let balance = await lightningClient.spendableOnchainBalanceSats()
        DispatchQueue.main.async {
            self.spendableBalance = balance
            self.isSpendableBalanceFinished = true
        }
    }

    func getTotalLightningBalanceSats() async {
        let balance = await lightningClient.totalLightningBalanceSats()
        DispatchQueue.main.async {
            self.totalLightningBalance = balance
            self.isTotalLightningBalanceFinished = true
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
        let color = lightningClient.getNetworkColor()
        DispatchQueue.main.async {
            self.networkColor = color
        }
    }
}
