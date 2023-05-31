//
//  PeerView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/2/23.
//

import SwiftUI
import WalletUI
import CodeScanner

struct PeerView: View {
    @ObservedObject var viewModel: PeerViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingScanner = false
    @State private var showingErrorAlert = false
    let pasteboard = UIPasteboard.general
    @FocusState private var isFocused: Bool
    
    var body: some View {
        
        ZStack {
            Color(uiColor: UIColor.systemBackground)
            
            VStack {
                
                HStack {
                    Spacer()
                    Button {
                        isShowingScanner = true
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.largeTitle)
                    }
                    .foregroundColor(viewModel.networkColor)
                    .padding(.top)
                }
                .padding(.top)
                
                Spacer()
                
                VStack(alignment: .leading) {
                    
                    HStack {
                        Spacer()
                        Button {
                            if pasteboard.hasStrings {
                                if let string = pasteboard.string {
                                    if let peer = string.parseConnectionInfo() {
                                        viewModel.nodeId = peer.nodeID
                                        viewModel.address = peer.address
                                    } else {
                                        print("Paste parsing did not work")
                                    }
                                } else {
                                    print("error: if let string = pasteboard.string")
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                    .font(.largeTitle)
                            }
                            .foregroundColor(viewModel.networkColor)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    
                    if viewModel.isProgressViewShowing {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                    
                    Text("Node ID")
                        .bold()
                    
                    ZStack {
                        TextField("03a5b467d7f...4c2b099b8250c", text: $viewModel.nodeId)
                            .frame(height: 48)
                            .truncationMode(.middle)
                            .padding(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 32))
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(lineWidth: 1.0)
                                    .foregroundColor(.secondary)
                            )
                        if !viewModel.nodeId.isEmpty {
                            HStack {
                                Spacer()
                                Button(action: {
                                    self.viewModel.nodeId = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                                .padding(.trailing, 8)
                            }
                        }
                    }
                }
                .padding()
                
                VStack(alignment: .leading) {
                    
                    Text("Address")
                        .bold()
                    
                    ZStack {
                        TextField("172.18.0.2:9735", text: $viewModel.address)
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
                
                Button {
                    self.viewModel.isProgressViewShowing = true
                    Task {
                        await viewModel.connect(
                            nodeId: viewModel.nodeId,
                            address: viewModel.address
                        )
                    }
                    if showingErrorAlert == true {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                    
                    if showingErrorAlert == false {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                    
                } label: {
                    Text("Connect Peer")
                }
                .buttonStyle(BitcoinOutlined(tintColor: viewModel.networkColor))
                .padding()
                
                Spacer()
                
            }
            .padding()
            .focused($isFocused)
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(
                    codeTypes: [.qr],
                    simulatedData: "LNBC10U1P3PJ257PP5YZTKWJCZ5FTL5LAXKAV23ZMZEKAW37ZK6KMV80PK4XAEV5QHTZ7QDPDWD3XGER9WD5KWM36YPRX7U3QD36KUCMGYP282ETNV3SHJCQZPGXQYZ5VQSP5USYC4LK9CHSFP53KVCNVQ456GANH60D89REYKDNGSMTJ6YW3NHVQ9QYYSSQJCEWM5CJWZ4A6RFJX77C490YCED6PEMK0UPKXHY89CMM7SCT66K8GNEANWYKZGDRWRFJE69H9U5U0W57RRCSYSAS7GADWMZXC8C6T0SPJAZUP6",
                    completion: handleScan
                )
            }
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
                viewModel.getColor()
            }
            
        }
        .ignoresSafeArea()
        
    }
    
}

extension PeerView {
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let result):
            let scannedQRCode = result.string.lowercased()
            if let peer = scannedQRCode.parseConnectionInfo() {
                viewModel.nodeId = peer.nodeID
                viewModel.address = peer.address
            } else {
                print("QR parsing did not work")
            }
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
}

struct PeerView_Previews: PreviewProvider {
    static var previews: some View {
        PeerView(viewModel: .init())
        PeerView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
