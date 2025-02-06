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
    @Published var balanceDetails: BalanceDetails = .empty
    @Published var unifiedBalance: UInt64 = 0
    @Published var isBalanceDetailsFinished: Bool = false
    @Published var isPriceFinished: Bool = false
    @Published var bitcoinViewError: MondayError?

    let priceClient: PriceClient
    var price: Double = 0.00
    var time: Int?

    var satsPrice: Double {
        let usdValue = Double(balanceDetails.totalOnchainBalanceSats).valueInUSD(price: price)
        return usdValue
    }

    var totalUSDValue: Double {
        let totalUSD = Double(unifiedBalance).valueInUSD(price: price)
        return totalUSD
    }

    init(
        walletClient: Binding<WalletClient>,
        priceClient: PriceClient
    ) {
        _walletClient = walletClient
        self.priceClient = priceClient
    }

    func getBalances() async {
        let balanceDetails = await walletClient.lightningClient.balanceDetails()
        let unifiedBalance =
            balanceDetails.totalOnchainBalanceSats + balanceDetails.totalLightningBalanceSats
        let copy = balanceDetails  // To avoid issues with non-sendable object
        await MainActor.run {
            self.balanceDetails = copy
            self.unifiedBalance = unifiedBalance
            self.isBalanceDetailsFinished = true
        }
    }

    func getPrices() async {
        do {
            let price = try await priceClient.fetchPrice()
            let copy = price  // To avoid issues with non-sendable object
            await MainActor.run {
                self.price = copy.usd
                self.time = price.time
                self.isPriceFinished = true
            }
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            let copy = errorString  // To avoid issues with non-sendable object
            await MainActor.run {
                self.bitcoinViewError = .init(title: copy.title, detail: copy.detail)
            }
        } catch let error {
            let copy = error  // To avoid issues with non-sendable object
            await MainActor.run {
                self.bitcoinViewError = .init(
                    title: "Unexpected error",
                    detail: copy.localizedDescription
                )
            }
        }
    }
}
