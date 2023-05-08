//
//  AddressView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/20/23.
//

import SwiftUI
import LightningDevKitNode
import WalletUI

class AddressViewModel: ObservableObject {
    @Published var address: String = ""
    @Published var synced: Bool = false
    @Published var balance: String = "0"
    @Published var totalBalance: String = "0"
    @Published var spendableBalance: String = "0"
    @Published var networkColor = Color.gray
    
    func syncWallets() {
        LightningNodeService.shared.syncWallets()
    }
    
    func getTotalOnchainBalanceSats() {
        guard let balance = LightningNodeService.shared.getTotalOnchainBalanceSats() else { return }
        let intBalance = Int(balance)
        let stringIntBalance = String(intBalance)
        print("LDKNodeMonday /// My total balance int string: \(stringIntBalance)")
        self.totalBalance = stringIntBalance
    }
    
    func getSpendableOnchainBalanceSats() {
        guard let balance = LightningNodeService.shared.getSpendableOnchainBalanceSats() else { return }
        let intBalance = Int(balance)
        let stringIntBalance = String(intBalance)
        print("LDKNodeMonday /// My spendable balance int string: \(stringIntBalance)")
        self.spendableBalance = stringIntBalance
    }
    
    func getAddress() {
        guard let address = LightningNodeService.shared.getAddress() else {
            self.address = ""
            return
        }
        self.address = address
    }
    
    func getColor() {
        let color = LightningNodeService.shared.networkColor
        self.networkColor = color
    }
    
}

struct AddressView: View {
    @StateObject var viewModel: AddressViewModel //ObservedObject
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: UIColor.systemBackground)
                
                VStack {
                    
                    Spacer()
                    
                    VStack {
                        
                        HStack(alignment: .lastTextBaseline) {
                            let totalBalance = viewModel.totalBalance.formattedAmount()
                            Text(totalBalance)
                                .textStyle(BitcoinTitle1())
                            Text("Total Sats")
                                .foregroundColor(.secondary)
                                .textStyle(BitcoinTitle5())
                                .baselineOffset(2)
                        }
                        
                        HStack(spacing: 4) {
                            let spendableBalance = viewModel.totalBalance.formattedAmount()
                            Text(spendableBalance)
                            Text("Spendable Sats")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                    }
                    
                    QRCodeView(address: viewModel.address)
                    
                    Text("Copy Address")
                        .bold()
                    
                    Text("Receive bitcoin from other wallets or exchanges with these addresses.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    HStack(alignment: .center) {
                        
                        ZStack {

                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 50.0, height: 50.0)
                                .foregroundColor(viewModel.networkColor)
                            
                            Image(systemName: "bitcoinsign")
                                .font(.title)
                                .foregroundColor(Color(uiColor: .systemBackground))
                                .bold()
                            
                        }
                        
                        VStack(alignment: .leading, spacing: 5.0) {
                            
                            Text("Bitcoin Network")
                                .font(.caption)
                                .bold()
                            
                            Text(viewModel.address)
                                .font(.caption)
                                .truncationMode(.middle)
                                .lineLimit(1)
                                .foregroundColor(.secondary)
                            
                        }
                        
                        Spacer()
                        
                        Button {
                            UIPasteboard.general.string = viewModel.address
                        } label: {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                    .font(.subheadline)
                            }
                            .bold()

                        }
                        
                    }
                    
                    Spacer()
                    
                }
                .padding()
                .navigationTitle("Address")
                .tint(viewModel.networkColor)
                .onAppear {
                    Task {
//                        viewModel.syncWallets()
                        viewModel.getTotalOnchainBalanceSats()
                        viewModel.getSpendableOnchainBalanceSats()
                        viewModel.getAddress()
                        viewModel.getColor()
                    }
                }
                
            }
            .ignoresSafeArea()
            
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AddressView(viewModel: .init())
        AddressView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
