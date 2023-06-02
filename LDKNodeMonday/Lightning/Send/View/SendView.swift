//
//  SendView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/28/23.
//

import SwiftUI
import WalletUI
import CodeScanner

struct SendView: View {
    @ObservedObject var viewModel: SendViewModel
    @State private var isShowingScanner = false
    @State private var showingParseErrorAlert = false
    let pasteboard = UIPasteboard.general
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: UIColor.systemBackground)
                
                VStack {
                    
                    VStack(spacing: 20) {
                        Button {
                            if pasteboard.hasStrings {
                                if let string = pasteboard.string {
                                    let lowercaseInvoice = string.lowercased()
                                    viewModel.invoice = lowercaseInvoice
                                } else {
                                    self.viewModel.parseError = .init(title: "Paste Parsing Error", detail: "Failed to parse the Pasteboard.")
                                }
                            } else {
                                self.viewModel.parseError = .init(title: "Paste Parsing Error", detail: "Nothing found in the Pasteboard.")
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
                        
                        Text("Invoice")
                            .bold()
                        
                        ZStack {
                            
                            TextField("lnbc10u1pwz...8f8r9ckzr0r", text: $viewModel.invoice)
                                .frame(height: 48)
                                .truncationMode(.middle)
                                .padding(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 32))
                                .cornerRadius(5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(lineWidth: 1.0)
                                        .foregroundColor(.secondary)
                                )
                            
                            if !viewModel.invoice.isEmpty {
                                
                                HStack {
                                    
                                    Spacer()
                                    
                                    Button {
                                        self.viewModel.invoice = ""
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
                    
                    NavigationLink(
                        destination:
                            SendConfirmationView(
                                viewModel: .init(
                                    invoice: viewModel.invoice
                                )
                            )
                    ) {
                        Text("Send")
                    }
                    .buttonStyle(BitcoinOutlined(tintColor: viewModel.networkColor))
                    
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
                    CodeScannerView(codeTypes: [.qr], simulatedData: "LNBC10U1P3PJ257PP5YZTKWJCZ5FTL5LAXKAV23ZMZEKAW37ZK6KMV80PK4XAEV5QHTZ7QDPDWD3XGER9WD5KWM36YPRX7U3QD36KUCMGYP282ETNV3SHJCQZPGXQYZ5VQSP5USYC4LK9CHSFP53KVCNVQ456GANH60D89REYKDNGSMTJ6YW3NHVQ9QYYSSQJCEWM5CJWZ4A6RFJX77C490YCED6PEMK0UPKXHY89CMM7SCT66K8GNEANWYKZGDRWRFJE69H9U5U0W57RRCSYSAS7GADWMZXC8C6T0SPJAZUP6", completion: handleScan)
                }
                .alert(isPresented: $showingParseErrorAlert) {
                    Alert(
                        title: Text(viewModel.parseError?.title ?? "Unknown"),
                        message: Text(viewModel.parseError?.detail ?? ""),
                        dismissButton: .default(Text("OK")) {
                            viewModel.parseError = nil
                        }
                    )
                }
                .onReceive(viewModel.$parseError) { errorMessage in
                    if errorMessage != nil {
                        showingParseErrorAlert = true
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

extension SendView {
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let result):
            let invoice = result.string.lowercased().replacingOccurrences(of: "lightning:", with: "")
            viewModel.invoice = invoice
        case .failure(let error):
            self.viewModel.parseError = .init(title: "Scan Error", detail: error.localizedDescription)
        }
    }
    
}

struct SendView_Previews: PreviewProvider {
    static var previews: some View {
        SendView(viewModel: .init())
        SendView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
