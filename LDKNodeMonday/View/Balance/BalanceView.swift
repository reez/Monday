//
//  BalanceView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/15/23.
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

struct BalanceView: View {
    @StateObject var viewModel: BalanceViewModel // ObservedObject
    @State private var isCopied = false
    @State private var showCheckmark = false
    @State private var showingErrorAlert = false
    @State private var isSheetPresented = false
    
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
                                Text(viewModel.totalBalance.formattedAmount())
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
                        isSheetPresented = true
                    }
                    .padding()
//                    .sheet(isPresented: $isSheetPresented) {
//                        AddressView(viewModel: .init())
//                    }
                    .sheet(isPresented: $isSheetPresented, onDismiss: {
                        // Perform any necessary actions upon dismissal of the sheet
                        // This closure will be called when the sheet is dismissed
                        // You can trigger the refresh process or update the data here
                        Task {
                            await viewModel.getTotalOnchainBalanceSats()
                            await viewModel.getSpendableOnchainBalanceSats()
                        }
                    }) {
                        AddressView(viewModel: .init())
                    }
                    .buttonStyle(BitcoinOutlined(tintColor: viewModel.networkColor))
                    .padding()
               
                    
                    Spacer()
                    
                }
                .padding()
                .navigationTitle("Balance")
                .tint(viewModel.networkColor)
                .alert(isPresented: $showingErrorAlert) {
                    Alert(
                        title: Text(viewModel.errorMessage?.title ?? "Unknown"),
                        message: Text(viewModel.errorMessage?.detail ?? ""),
                        dismissButton: .default(Text("OK")) {
                            viewModel.errorMessage = nil
                        }
                    )
                }
                .onReceive(viewModel.$errorMessage) { errorMessage in
                    if errorMessage != nil {
                        showingErrorAlert = true
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
        BalanceView(viewModel: .init())
        BalanceView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
