//
//  PeerView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/2/23.
//

import BitcoinUI
import CodeScanner
import SwiftUI

struct PeerView: View {
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var isFocused: Bool
    @ObservedObject var viewModel: PeerViewModel
    @State private var isShowingScanner = false
    @State private var showingPeerViewErrorAlert = false
    let pasteboard = UIPasteboard.general

    var body: some View {

        VStack {

            if viewModel.isProgressViewShowing {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }

            VStack(spacing: 20) {

                VStack(alignment: .leading) {
                    Text("Node ID")
                        .font(.subheadline.weight(.medium))
                    TextField(
                        "03a5b467d7f...4c2b099b8250c",
                        text: $viewModel.nodeId
                    )
                    .frame(width: 260, height: 48)
                    .tint(.accentColor)
                    .padding([.leading, .trailing], 20)
                    .keyboardType(.numbersAndPunctuation)
                    .truncationMode(.middle)
                    .submitLabel(.next)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.accentColor, lineWidth: 2)
                    ).onChange(of: viewModel.nodeId) { oldValue, newValue in
                        viewModel.nodeId = newValue.replacingOccurrences(of: " ", with: "")
                    }
                }

                VStack(alignment: .leading) {
                    Text("Address")
                        .font(.subheadline.weight(.medium))
                    TextField(
                        "172.18.0.2:9735",
                        text: $viewModel.address
                    )
                    .frame(width: 260, height: 48)
                    .tint(.accentColor)
                    .padding([.leading, .trailing], 20)
                    .keyboardType(.numbersAndPunctuation)
                    .truncationMode(.middle)
                    .submitLabel(.next)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.accentColor, lineWidth: 2)
                    ).onChange(of: viewModel.address) { oldValue, newValue in
                        viewModel.address = newValue.replacingOccurrences(of: " ", with: "")
                    }
                }

            }
            .padding(.horizontal)

            Spacer()

            HStack(spacing: 60) {

                Button("Paste", systemImage: "doc.on.clipboard") {
                    if pasteboard.hasStrings {
                        if let string = pasteboard.string {
                            if let peer = string.parseConnectionInfo() {
                                viewModel.nodeId = peer.nodeID
                                viewModel.address = peer.address
                            } else {
                                self.viewModel.peerViewError = .init(
                                    title: "Paste Parsing Error",
                                    detail: "Failed to parse the Pasteboard."
                                )
                            }
                        } else {
                            self.viewModel.peerViewError = .init(
                                title: "Paste Parsing Error",
                                detail: "Nothing found in the Pasteboard."
                            )
                        }
                    }
                }

                Button("Scan", systemImage: "qrcode.viewfinder") {
                    isShowingScanner = true
                }

            }
            .buttonStyle(.automatic)
            .controlSize(.mini)

            Spacer()

            Text(
                "Enter, paste or scan the required information to connect with another lightning node."
            )
            .font(.footnote)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: false)
            .padding(.horizontal, 30)

            Spacer()

            Button("Connect Peer") {
                self.viewModel.isProgressViewShowing = true
                Task {
                    await viewModel.connect(
                        nodeId: viewModel.nodeId,
                        address: viewModel.address
                    )
                }
                if showingPeerViewErrorAlert == true {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }

                if showingPeerViewErrorAlert == false {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }

            }
            .disabled(viewModel.nodeId.isEmpty || viewModel.address.isEmpty)
            .buttonStyle(BitcoinFilled(tintColor: .accentColor, isCapsule: true))
            .padding(.horizontal)
            .padding(.bottom, 40.0)

        }.dynamicTypeSize(...DynamicTypeSize.accessibility1)  // Sets max dynamic size for all Text
        .navigationTitle("Add Peer")
        .navigationBarTitleDisplayMode(.inline)
        .padding()
        .focused($isFocused)
        .onAppear {
            viewModel.getColor()
        }
        .onReceive(viewModel.$peerViewError) { errorMessage in
            if errorMessage != nil {
                showingPeerViewErrorAlert = true
            }
        }
        .alert(isPresented: $showingPeerViewErrorAlert) {
            Alert(
                title: Text(viewModel.peerViewError?.title ?? "Unknown"),
                message: Text(viewModel.peerViewError?.detail ?? ""),
                dismissButton: .default(Text("OK")) {
                    viewModel.peerViewError = nil
                }
            )
        }
        .sheet(isPresented: $isShowingScanner) {
            CodeScannerView(
                codeTypes: [.qr],
                simulatedData:
                    "LNBC10U1P3PJ257PP5YZTKWJCZ5FTL5LAXKAV23ZMZEKAW37ZK6KMV80PK4XAEV5QHTZ7QDPDWD3XGER9WD5KWM36YPRX7U3QD36KUCMGYP282ETNV3SHJCQZPGXQYZ5VQSP5USYC4LK9CHSFP53KVCNVQ456GANH60D89REYKDNGSMTJ6YW3NHVQ9QYYSSQJCEWM5CJWZ4A6RFJX77C490YCED6PEMK0UPKXHY89CMM7SCT66K8GNEANWYKZGDRWRFJE69H9U5U0W57RRCSYSAS7GADWMZXC8C6T0SPJAZUP6",
                completion: handleScan
            )
        }

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
                self.viewModel.peerViewError = .init(
                    title: "QR Parsing Error",
                    detail: "Failed to parse the QR code."
                )
            }
        case .failure(let error):
            self.viewModel.peerViewError = .init(
                title: "Scan Error",
                detail: error.localizedDescription
            )
        }
    }

}

#if DEBUG
    #Preview {
        PeerView(viewModel: .init())
    }
#endif
