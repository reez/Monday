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
    @Published var balance: String = "0"
    
    func syncWallets() {
        LightningNodeService.shared.syncWallets()
    }
    
    func getTotalOnchainBalanceSats() {
        guard let balance = LightningNodeService.shared.getTotalOnchainBalanceSats() else { return }
        let intBalance = Int(balance)
        let stringIntBalance = String(intBalance)
        print("My balance int string: \(stringIntBalance)")
        self.balance = stringIntBalance
    }
    
}

struct BalanceView: View {
    @ObservedObject var viewModel: BalanceViewModel

    var body: some View {
        
        NavigationView {
            
        ZStack {
            Color(uiColor: UIColor.systemBackground)
            
            VStack(spacing: 20.0) {
                Text(viewModel.balance)
                    .textStyle(BitcoinTitle1())
                Text("Sats")
                    .foregroundColor(.secondary)
                    .textStyle(BitcoinTitle5())
                
                Button {
                    viewModel.getTotalOnchainBalanceSats()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
                
            }
            .padding()
            .navigationTitle("Balance")
            .onAppear {
                Task {
                    viewModel.getTotalOnchainBalanceSats
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
