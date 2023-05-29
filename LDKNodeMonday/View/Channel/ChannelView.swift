//
//  ChannelView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/21/23.
//

import SwiftUI
import LightningDevKitNode
import WalletUI
import CodeScanner

class ChannelViewModel: ObservableObject {
    @Published var address: SocketAddr = ""
    @Published var channelAmountSats: String = ""
    @Published var errorMessage: MondayNodeError?
    @Published var networkColor = Color.gray
    @Published var nodeId: PublicKey = ""
    @Published var isOpenChannelFinished: Bool = false
    @Published var isProgressViewShowing: Bool = false

    
    func openChannel(nodeId: PublicKey, address: SocketAddr, channelAmountSats: UInt64, pushToCounterpartyMsat: UInt64?) async {
        DispatchQueue.main.async {
            self.isProgressViewShowing = true
        }
        do {
            try await LightningNodeService.shared.connectOpenChannel(
                nodeId: nodeId,
                address: address,
                channelAmountSats: channelAmountSats,
                pushToCounterpartyMsat: pushToCounterpartyMsat
            )
            DispatchQueue.main.async {
                self.errorMessage = nil
                self.isOpenChannelFinished = true
                self.isProgressViewShowing = false
            }
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.isProgressViewShowing = false
                self.errorMessage = .init(title: errorString.title, detail: errorString.detail)
            }
        } catch {
            DispatchQueue.main.async {
                self.isProgressViewShowing = false
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

struct ChannelView: View {
    @ObservedObject var viewModel: ChannelViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingScanner = false
    @State private var showingErrorAlert = false
    let pasteboard = UIPasteboard.general
    @State private var keyboardOffset: CGFloat = 0
    @FocusState private var isFocused: Bool

    var body: some View {
        
        ZStack {
            Color(uiColor: UIColor.systemBackground)
            
            ScrollView {
                
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
                                
                                // [Pasteboard] ...requesting item failed with error: Error Domain=PBErrorDomain Code=13 "Operation not authorized." UserInfo={NSLocalizedDescription=Operation not authorized.}

                                    if pasteboard.hasStrings {
                                        if let string = pasteboard.string {
                                            if let peer = string.parseConnectionInfo() {
                                                viewModel.nodeId = peer.nodeID
                                                viewModel.address = peer.address
                                            } else {
                                                print("Paste parsing did not work")
                                                self.viewModel.errorMessage = .init(title: "Unexpected error", detail: "Connection info could not be parsed.")
                                            }
                                        } else {
                                            print("error: if let string = pasteboard.string")
                                            self.viewModel.errorMessage = .init(title: "Unexpected error", detail: "Text from Pasteboard not found.")
                                        }
                                    } else {
                                        print("pasteboard has no strings")
                                        DispatchQueue.main.async {
                                            self.viewModel.errorMessage = .init(title: "Unexpected error", detail: "Pasteboard has no text.")
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
                                .keyboardType(.numbersAndPunctuation)
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
                                .keyboardType(.numbersAndPunctuation)
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
                    
                    VStack(alignment: .leading) {
                        
                        Text("Sats")
                            .bold()
                        
                        ZStack {
                            
                            TextField("125000", text: $viewModel.channelAmountSats)
                                .keyboardType(.numbersAndPunctuation)
                                .frame(height: 48)
                                .padding(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 32))
                                .cornerRadius(5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(lineWidth: 1.0)
                                        .foregroundColor(.secondary)
                                )
                            
                            if !viewModel.channelAmountSats.isEmpty {
                                
                                HStack {
                                    
                                    Spacer()
                                    
                                    Button {
                                        self.viewModel.channelAmountSats = ""
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
                        isFocused = false
                        let channelAmountSats = UInt64(viewModel.channelAmountSats) ?? UInt64(101010)
                        Task {
                            await viewModel.openChannel(
                                nodeId: viewModel.nodeId,
                                address: viewModel.address,
                                channelAmountSats: channelAmountSats,
                                pushToCounterpartyMsat: nil // TODO: actually make this inputtable
                            )
                            
                            if viewModel.isOpenChannelFinished == true {
                                print("True")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            }
                            
//                            if showingErrorAlert == false {
////                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
////                                    self.presentationMode.wrappedValue.dismiss()
////                                }
//                                print("error false")
//                            }
//                            
//                            if showingErrorAlert == true {
////                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
////                                    self.presentationMode.wrappedValue.dismiss()
////                                }
//                                print("error true")
//                            }
                            
                        }
                        
 
                        
                    } label: {
                        Text("Open Channel")
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
            .offset(y: keyboardOffset)
//            .animation(.easeInOut)
            .onChange(of: keyboardOffset) { _ in
                        withAnimation {
                            // Empty closure to trigger animation
                        }
                    }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                let height = value?.height ?? 0
                keyboardOffset = -height / 2
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                keyboardOffset = 0
            }
            
        }
        .ignoresSafeArea()
        
    }
    
}

extension ChannelView {
    
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

struct ChannelView_Previews: PreviewProvider {
    static var previews: some View {
        ChannelView(viewModel: .init())
        ChannelView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
