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
    @Published var errorMessage: MondayNodeError?
    
    func getTotalOnchainBalanceSats() async {
        do {
            let balance = try await LightningNodeService.shared.getTotalOnchainBalanceSats()
            let intBalance = Int(balance)
            let stringIntBalance = String(intBalance)
            print("LDKNodeMonday /// My total balance int string: \(stringIntBalance)")
            DispatchQueue.main.async {
                self.totalBalance = stringIntBalance
            }
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.errorMessage = .init(title: errorString.title, detail: errorString.detail)
            }
            print("Title: \(errorString.title) ... Detail: \(errorString.detail))")
        } catch {
            print("LDKNodeMonday /// error getting connect: \(error.localizedDescription)")
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
            print("LDKNodeMonday /// My spendable balance int string: \(stringIntBalance)")
            DispatchQueue.main.async {
                self.spendableBalance = stringIntBalance
            }
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.errorMessage = .init(title: errorString.title, detail: errorString.detail)
            }
            print("Title: \(errorString.title) ... Detail: \(errorString.detail))")
        } catch {
            print("LDKNodeMonday /// error getting connect: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = .init(title: "Unexpected error", detail: error.localizedDescription)
            }
        }
    }
    
    func newFundingAddress() async {
        do {
            let address = try await LightningNodeService.shared.newFundingAddress() //else {
            DispatchQueue.main.async {
                self.address = address
            }
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.errorMessage = .init(title: errorString.title, detail: errorString.detail)
            }
            print("Title: \(errorString.title) ... Detail: \(errorString.detail))")
        } catch {
            print("LDKNodeMonday /// error getting connect: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = .init(title: "Unexpected error", detail: error.localizedDescription)
            }
        }
    }
    
    func getColor() {
        let color = LightningNodeService.shared.networkColor
        self.networkColor = color
    }
    
}

struct AddressView: View {
    @StateObject var viewModel: AddressViewModel // ObservedObject
    @State private var showingErrorAlert = false
    @State private var isCopied = false
    @State private var showCheckmark = false

    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: UIColor.systemBackground)
                
                VStack {
                    
                    Spacer()
                    
                    VStack {
                        
                        HStack(alignment: .lastTextBaseline) {
                            
                            Text(viewModel.totalBalance.formattedAmount())
                                .textStyle(BitcoinTitle1())
                            
                            Text("Total Sats")
                                .foregroundColor(.secondary)
                                .textStyle(BitcoinTitle5())
                                .baselineOffset(2)
                            
                        }
                        
                        HStack(spacing: 4) {
                            Text(viewModel.totalBalance.formattedAmount())
                            Text("Spendable Sats")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                    }
                    
                    QRCodeView(address: viewModel.address)
                    
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
                            print("Copied address: \(viewModel.address)")
                            isCopied = true
                            showCheckmark = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isCopied = false
                                showCheckmark = false
                            }
                            
                        } label: {
                            
                            HStack {
                                Image(systemName: showCheckmark ? "checkmark" : "doc.on.doc")
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
                        await viewModel.newFundingAddress()
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
