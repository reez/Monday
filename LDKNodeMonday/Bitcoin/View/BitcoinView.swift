//
//  BitcoinView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/15/23.
//

import SwiftUI
import WalletUI

struct BitcoinView: View {
    @StateObject var viewModel: BitcoinViewModel
    @State private var isCopied = false
    @State private var showCheckmark = false
    @State private var showingBitcoinViewErrorAlert = false
    @State private var isAddressSheetPresented = false
    @State private var isSendSheetPresented = false

    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: UIColor.systemBackground)
                
                VStack {
                    
                    Spacer()
                    
                    VStack {
                        HStack(alignment: .lastTextBaseline) {
                            if viewModel.isTotalBalanceFinished {
                                Text(viewModel.totalBalance.formattedAmount())
                                    .textStyle(BitcoinTitle1())
                            } else {
                                ProgressView()
                            }
                            Text("Total Sats")
                                .foregroundColor(.secondary)
                                .textStyle(BitcoinTitle5())
                                .baselineOffset(2)
                        }
                        HStack(spacing: 4) {
                            if viewModel.isSpendableBalanceFinished {
                                Text(viewModel.spendableBalance.formattedAmount())
                            } else {
                                ProgressView()
                            }
                            Text("Spendable Sats")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    
                    List {
                        Section(header: Text("*Transaction List Placeholder*")) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Item 11111111111111111")
                                    Spacer()
                                    Text("Item 1111")
                                }
                                Text("Item 111111111")
                            }
                            .redacted(reason: .placeholder)
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Item 11111111111111111")
                                    Spacer()
                                    Text("Item 1111111")
                                }
                                Text("Item 1111111111111")
                            }
                            .redacted(reason: .placeholder)
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Item 11111111111111111")
                                    Spacer()
                                    Text("Item 11")
                                }
                                Text("Item 1111")
                            }
                            .redacted(reason: .placeholder)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .listStyle(PlainListStyle())
                    .padding()
                    .refreshable {
                        await viewModel.getTotalOnchainBalanceSats()
                        await viewModel.getSpendableOnchainBalanceSats()
                    }
                    
                    Button("Get New Address") {
                        isAddressSheetPresented = true
                    }
                    .padding()
                    .sheet(isPresented: $isAddressSheetPresented, onDismiss: {
                        Task {
                            await viewModel.getTotalOnchainBalanceSats()
                            await viewModel.getSpendableOnchainBalanceSats()
                        }
                    }) {
                        AddressView(viewModel: .init())
                    }
                    .buttonStyle(BitcoinOutlined(tintColor: viewModel.networkColor))
                    
                    Button("Send All To Address") {
                        isSendSheetPresented = true
                    }
                    .padding()
                    .sheet(isPresented: $isSendSheetPresented, onDismiss: {
                        Task {
                            await viewModel.getTotalOnchainBalanceSats()
                            await viewModel.getSpendableOnchainBalanceSats()
                        }
                    }) {
                        SendBitcoinView(viewModel: .init())
                    }
                    .buttonStyle(BitcoinOutlined(tintColor: viewModel.networkColor))
                    
                    Spacer()
                    
                }
                .padding()
                .navigationTitle("Balance")
                .tint(viewModel.networkColor)
                .alert(isPresented: $showingBitcoinViewErrorAlert) {
                    Alert(
                        title: Text(viewModel.bitcoinViewError?.title ?? "Unknown"),
                        message: Text(viewModel.bitcoinViewError?.detail ?? ""),
                        dismissButton: .default(Text("OK")) {
                            viewModel.bitcoinViewError = nil
                        }
                    )
                }
                .onReceive(viewModel.$bitcoinViewError) { errorMessage in
                    if errorMessage != nil {
                        showingBitcoinViewErrorAlert = true
                    }
                }
                .onAppear {
                    Task {
                        await viewModel.getTotalOnchainBalanceSats()
                        await viewModel.getSpendableOnchainBalanceSats()
                        viewModel.getColor()
                    }
                }
                
            }
            .ignoresSafeArea()
            
        }
        
    }
    
}

struct BalanceView_Previews: PreviewProvider {
    static var previews: some View {
        BitcoinView(viewModel: .init())
        BitcoinView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
