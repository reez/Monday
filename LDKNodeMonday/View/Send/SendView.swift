//
//  SendView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/28/23.
//

import SwiftUI
import LightningDevKitNode
import WalletUI
import CodeScanner

class SendViewModel: ObservableObject {
    @Published var invoice: PublicKey = ""
    @Published var networkColor = Color.gray
    
    func getColor() {
        let color = LightningNodeService.shared.networkColor
        self.networkColor = color
    }
    
}

struct SendView: View {
    @ObservedObject var viewModel: SendViewModel
    @State private var isShowingScanner = false
    let pasteboard = UIPasteboard.general
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: UIColor.systemBackground)
                
                VStack {
                                        
                    VStack(spacing: 20) {

                        Button {
                            isShowingScanner = true
                        } label: {
                            Image(systemName: "qrcode")
                            Text("Scan")
                        }
                        .foregroundColor(viewModel.networkColor)
                        
                        Button {
                            
                            if pasteboard.hasStrings {
                                if let string = pasteboard.string {
                                    let lowercaseInvoice = string.lowercased()
                                    viewModel.invoice = lowercaseInvoice
                                } else {
                                    print("error: if let string = pasteboard.string")
                                }
                            }
                            
                        } label: {
                            
                            HStack {
                                Image(systemName: "doc.on.clipboard.fill")
                                Text("Paste")
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
                                .padding(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18))
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
                .navigationTitle("Send")
                .sheet(isPresented: $isShowingScanner) {
                    CodeScannerView(codeTypes: [.qr], simulatedData: "LNBC10U1P3PJ257PP5YZTKWJCZ5FTL5LAXKAV23ZMZEKAW37ZK6KMV80PK4XAEV5QHTZ7QDPDWD3XGER9WD5KWM36YPRX7U3QD36KUCMGYP282ETNV3SHJCQZPGXQYZ5VQSP5USYC4LK9CHSFP53KVCNVQ456GANH60D89REYKDNGSMTJ6YW3NHVQ9QYYSSQJCEWM5CJWZ4A6RFJX77C490YCED6PEMK0UPKXHY89CMM7SCT66K8GNEANWYKZGDRWRFJE69H9U5U0W57RRCSYSAS7GADWMZXC8C6T0SPJAZUP6", completion: handleScan)
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
            print("Scanning succeeded: \(result)")
            print("invoice: \n \(result.string)")
            let invoice = result.string.lowercased()
            viewModel.invoice = invoice
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
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
