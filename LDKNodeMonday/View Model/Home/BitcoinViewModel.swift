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
    @Published var balances: BalanceDetails = .empty
    @Published var unifiedBalance: UInt64 = 0
    @Published var transactions: [PaymentDetails] = []
    @Published var isBalancesFinished: Bool = false
    @Published var isPriceFinished: Bool = false

    let lightningClient: LightningNodeClient
    let priceClient: PriceClient
    var price: Double = 0.00
    var time: Int?

    var totalUSDValue: String {
        let totalUSD = unifiedBalance.formattedSatsAsUSD(price: price)
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

    func update() async {
        async let balancesTask: () = getBalances()
        async let pricesTask: () = getPrices()
        async let statusTask: () = getStatus()
        async let transactionsTask: () = getTransactions()

        await balancesTask
        await pricesTask
        await statusTask
        await transactionsTask

        getColor()
    }

    func getStatus() async {
        let status = lightningClient.status()
        let sCopy = status  // To avoid issues with non-sendable object
        await MainActor.run {
            self.status = sCopy
            self.isStatusFinished = true
        }
    }

    func getBalances() async {
        let balances = await lightningClient.balances()
        let bdCopy = balances  // To avoid issues with non-sendable object
        await MainActor.run {
            self.balances = bdCopy
            self.unifiedBalance =
                balances.totalOnchainBalanceSats + balances.totalLightningBalanceSats
            self.isBalancesFinished = true
        }
    }

    func getPrices() async {
        do {
            let price = try await priceClient.fetchPrice()
            await MainActor.run {
                self.price = price.usd
                self.time = price.time
                self.isPriceFinished = true
            }
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            await MainActor.run {
                self.bitcoinViewError = .init(title: errorString.title, detail: errorString.detail)
            }
        } catch {
            await MainActor.run {
                self.bitcoinViewError = .init(
                    title: "Unexpected error",
                    detail: error.localizedDescription
                )
            }
        }
    }

    func getTransactions() async {
        let transactions = lightningClient.listPayments()
        let tCopy = transactions
        await MainActor.run {
            self.transactions = tCopy
        }
    }

    func getColor() {
        let color = lightningClient.getNetworkColor()
        DispatchQueue.main.async {
            self.networkColor = color
        }
    }
}
