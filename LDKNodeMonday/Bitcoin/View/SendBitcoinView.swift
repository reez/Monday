//
//  SendBitcoinView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 6/7/23.
//

import SwiftUI
import WalletUI
import CodeScanner

struct SendBitcoinView: View {
    @ObservedObject var viewModel: SendBitcoinViewModel
    @State private var isShowingScanner = false
    @State private var isCopied = false
    @State private var showCheckmark = false
    @State private var showingBitcoinViewErrorAlert = false
    let pasteboard = UIPasteboard.general

    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: UIColor.systemBackground)
                
                VStack {
                    
                    HStack(alignment: .center, spacing: 4) {
                        Text(viewModel.spendableBalance.formattedAmount())
                            .textStyle(BitcoinTitle1())
                        Text("Sats")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 50.0)
                    
                    VStack(spacing: 20) {
                        Button {
                            if pasteboard.hasStrings {
                                if let string = pasteboard.string {
                                    let lowercaseAddress = string.lowercased()
                                    viewModel.address = lowercaseAddress
                                } else {
                                    self.viewModel.sendViewError = .init(title: "Paste Parsing Error", detail: "Failed to parse the Pasteboard.")
                                }
                            } else {
                                self.viewModel.sendViewError = .init(title: "Paste Parsing Error", detail: "Nothing found in the Pasteboard.")
                            }
                        } label: {
                            HStack {
                                Image(systemName: "doc.on.clipboard.fill")
                                    .font(.largeTitle)
                            }
                            .foregroundColor(viewModel.networkColor)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        
                        Text("Address")
                            .bold()
                        
                        ZStack {
                            
                            TextField("1BvBMSEYstWet...m4GFg7xJaNVN2", text: $viewModel.address)
                                .frame(height: 48)
                                .truncationMode(.middle)
                                .padding(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 32))
                                .cornerRadius(5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(lineWidth: 1.0)
                                        .foregroundColor(.secondary)
                                )
                            
                            if !viewModel.address.isEmpty {
                                HStack {
                                    Spacer()
                                    Button {
                                        self.viewModel.address = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.trailing, 8)
                                }
                            }
                            
                        }
                        
                    }
                    .padding()
                    
                    if viewModel.txId.isEmpty {
                        Button {
                            Task {
                                await viewModel.sendAllToOnchain(address: viewModel.address)
                            }
                        } label: {
                            Text("Send All")
                        }
                        .buttonStyle(BitcoinOutlined(tintColor: viewModel.networkColor))
                    } else {
                        VStack {
                            Text("Transaction ID")
                            HStack(alignment: .center) {
                                Text(viewModel.txId)
                                    .truncationMode(.middle)
                                    .lineLimit(1)
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                                Button {
                                    UIPasteboard.general.string = viewModel.txId
                                    isCopied = true
                                    showCheckmark = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        isCopied = false
                                        showCheckmark = false
                                    }
                                } label: {
                                    HStack {
                                        withAnimation {
                                            Image(systemName: showCheckmark ? "checkmark" : "doc.on.doc")
                                                .font(.subheadline)
                                        }
                                    }
                                    .bold()
                                    .foregroundColor(viewModel.networkColor)
                                }
                                
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                }
                .padding()
                .toolbar{
                    Button {
                        isShowingScanner = true
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.largeTitle)
                    }
                    .foregroundColor(viewModel.networkColor)
                }
                .sheet(isPresented: $isShowingScanner) {
                    CodeScannerView(codeTypes: [.qr], simulatedData: "1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2", completion: handleScan)
                }
                .alert(isPresented: $showingBitcoinViewErrorAlert) {
                    Alert(
                        title: Text(viewModel.sendViewError?.title ?? "Unknown"),
                        message: Text(viewModel.sendViewError?.detail ?? ""),
                        dismissButton: .default(Text("OK")) {
                            viewModel.sendViewError = nil
                        }
                    )
                }
                .onReceive(viewModel.$sendViewError) { errorMessage in
                    if errorMessage != nil {
                        showingBitcoinViewErrorAlert = true
                    }
                }
                .onAppear {
                    viewModel.getColor()
                }
                
            }
            .ignoresSafeArea()
            
        }
        
    }
}

extension SendBitcoinView {
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let result):
            let address = result.string.lowercased().replacingOccurrences(of: "bitcoin:", with: "")
            let components = address.components(separatedBy: "?")
            if let bitcoinAddress = components.first {
                viewModel.address = bitcoinAddress
            } else {
                self.viewModel.sendViewError = .init(title: "No Address", detail: "No Bitcoin Address found")
            }
        case .failure(let error):
            self.viewModel.sendViewError = .init(title: "Scan Error", detail: error.localizedDescription)
        }
    }
}

struct SendBitcoinView_Previews: PreviewProvider {
    static var previews: some View {
        SendBitcoinView(viewModel: .init(spendableBalance: "1000000"))
        SendBitcoinView(viewModel: .init(spendableBalance: "1010101"))
            .environment(\.colorScheme, .dark)
    }
}
