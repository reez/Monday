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
    @ObservedObject var viewModel: PeerViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingScanner = false
    @State private var showingPeerViewErrorAlert = false
    let pasteboard = UIPasteboard.general
    @FocusState private var isFocused: Bool

    var body: some View {

        ZStack {
            Color(uiColor: UIColor.systemBackground)

            VStack {

                VStack(alignment: .leading) {

                    HStack {

                        Button {
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
                        } label: {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                    .minimumScaleFactor(0.5)
                                Text("Paste")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }
                            .frame(width: 100, height: 25)
                        }

                        Spacer()

                        Button {
                            isShowingScanner = true
                        } label: {
                            HStack {
                                Image(systemName: "qrcode.viewfinder")
                                    .minimumScaleFactor(0.5)
                                Text("Scan")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }
                            .frame(width: 100, height: 25)
                        }

                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.bordered)
                    .tint(viewModel.networkColor)
                    .padding(.bottom)

                }
                .padding()

                if viewModel.isProgressViewShowing {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }

                VStack(alignment: .leading) {

                    Text("Node ID")
                        .minimumScaleFactor(0.75)
                        .bold()

                    ZStack {
                        TextField(
                            "03a5b467d7f...4c2b099b8250c",
                            text: $viewModel.nodeId
                        )
                        .truncationMode(.middle)
                        .submitLabel(.next)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 32))

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

                    Text("Address")
                        .minimumScaleFactor(0.5)
                        .bold()

                    ZStack {

                        TextField(
                            "172.18.0.2:9735",
                            text: $viewModel.address
                        )
                        .truncationMode(.middle)
                        .submitLabel(.done)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 32))

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
                .padding(.horizontal)
                .padding(.bottom, 10)

                Button {
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

                } label: {
                    Text("Connect Peer")
                        .bold()
                        .foregroundColor(Color(uiColor: UIColor.systemBackground))
                        .frame(maxWidth: .infinity)
                        .padding(.all, 8)
                }
                .buttonBorderShape(.capsule)
                .buttonStyle(.borderedProminent)
                .tint(viewModel.networkColor)
                .frame(width: 300, height: 50)
                .padding(.horizontal)

                Spacer()

            }
            .padding()
            .focused($isFocused)
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(
                    codeTypes: [.qr],
                    simulatedData:
                        "LNBC10U1P3PJ257PP5YZTKWJCZ5FTL5LAXKAV23ZMZEKAW37ZK6KMV80PK4XAEV5QHTZ7QDPDWD3XGER9WD5KWM36YPRX7U3QD36KUCMGYP282ETNV3SHJCQZPGXQYZ5VQSP5USYC4LK9CHSFP53KVCNVQ456GANH60D89REYKDNGSMTJ6YW3NHVQ9QYYSSQJCEWM5CJWZ4A6RFJX77C490YCED6PEMK0UPKXHY89CMM7SCT66K8GNEANWYKZGDRWRFJE69H9U5U0W57RRCSYSAS7GADWMZXC8C6T0SPJAZUP6",
                    completion: handleScan
                )
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
            .onReceive(viewModel.$peerViewError) { errorMessage in
                if errorMessage != nil {
                    showingPeerViewErrorAlert = true
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

struct PeerView_Previews: PreviewProvider {
    static var previews: some View {
        PeerView(viewModel: .init())
        PeerView(viewModel: .init())
            .environment(\.sizeCategory, .accessibilityLarge)
        PeerView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
