//
//  BalanceView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/24/23.
//

import SwiftUI
import LightningDevKitNode
import WalletUI

class BalanceViewModel: ObservableObject {
    @Published var totalBalance: String = "0"
    @Published var spendableBalance: String = "0"

    func syncWallets() {
        LightningNodeService.shared.syncWallets()
    }
    
    func getTotalOnchainBalanceSats() {
        guard let balance = LightningNodeService.shared.getTotalOnchainBalanceSats() else { return }
        let intBalance = Int(balance)
        let stringIntBalance = String(intBalance)
        print("My total balance int string: \(stringIntBalance)")
        self.totalBalance = stringIntBalance
    }
    
    func getSpendableOnchainBalanceSats() {
        guard let balance = LightningNodeService.shared.getSpendableOnchainBalanceSats() else { return }
        let intBalance = Int(balance)
        let stringIntBalance = String(intBalance)
        print("My spendable balance int string: \(stringIntBalance)")
        self.spendableBalance = stringIntBalance
    }
    
}

struct BalanceView: View {
    @ObservedObject var viewModel: BalanceViewModel
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: UIColor.systemBackground)
                
                VStack(spacing: 20.0) {
                    
                    VStack {
                        Text(viewModel.totalBalance)
                            .textStyle(BitcoinTitle1())
                        Text("Total Sats")
                            .foregroundColor(.secondary)
                            .textStyle(BitcoinTitle5())
                    }
                    
                    VStack {
                        Text(viewModel.spendableBalance)
                            .textStyle(BitcoinTitle1())
                        Text("Spendable Sats")
                            .foregroundColor(.secondary)
                            .textStyle(BitcoinTitle5())
                    }
                    
                    Button {
                        viewModel.syncWallets()
                        viewModel.getTotalOnchainBalanceSats()
                        viewModel.getSpendableOnchainBalanceSats()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    
                }
                .padding()
                .navigationTitle("Balance")
                .onAppear {
                    Task {
                        viewModel.syncWallets()
                        viewModel.getTotalOnchainBalanceSats()
                        viewModel.getSpendableOnchainBalanceSats()
                    }
                }
            }
            .ignoresSafeArea()
            
        }
        
    }
    
}

struct BalanceView_Previews: PreviewProvider {
    static var previews: some View {
        BalanceView(viewModel: .init())
        BalanceView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
