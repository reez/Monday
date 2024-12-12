//
//  ChannelAddView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/21/23.
//

import BitcoinUI
import CodeScanner
import SwiftUI

struct ChannelAddView: View {
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var isFocused: Bool
    @ObservedObject var viewModel: ChannelAddViewModel
    @State private var isShowingScanner = false
    @State private var showingChannelAddViewErrorAlert = false
    @State private var keyboardOffset: CGFloat = 0
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

                VStack(alignment: .leading) {
                    Text("Channel capacity")
                        .font(.subheadline.weight(.medium))
                    TextField(
                        125000.formatted(),
                        text: $viewModel.channelAmountSats
                    )
                    .frame(width: 260, height: 48)
                    .tint(.accentColor)
                    .padding([.leading, .trailing], 20)
                    .keyboardType(.numberPad)
                    .submitLabel(.done)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.accentColor, lineWidth: 2)
                    )
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
                                viewModel.channelAddViewError = .init(
                                    title: "Unexpected error",
                                    detail: "Connection info could not be parsed."
                                )
                            }
                        } else {
                            DispatchQueue.main.async {
                                viewModel.channelAddViewError = .init(
                                    title: "Unexpected error",
                                    detail: "Failed to retrieve string from pasteboard."
                                )
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            viewModel.channelAddViewError = .init(
                                title: "Unexpected error",
                                detail: "Pasteboard has no text."
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
                "Enter, paste or scan the required information to open a channel with another lightning node."
            )
            .font(.footnote)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: false)
            .padding(.horizontal, 30)

            Spacer()

            Button("Open Channel") {
                isFocused = false
                let channelAmountSats = UInt64(viewModel.channelAmountSats) ?? UInt64(101010)
                Task {
                    await viewModel.openChannel(
                        nodeId: viewModel.nodeId,
                        address: viewModel.address,
                        channelAmountSats: channelAmountSats,
                        pushToCounterpartyMsat: nil
                    )
                    if viewModel.isOpenChannelFinished == true {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .disabled(
                viewModel.nodeId.isEmpty || viewModel.address.isEmpty
                    || viewModel.channelAmountSats.isEmpty
            )
            .buttonStyle(BitcoinFilled(tintColor: .accentColor, isCapsule: true))
            .padding(.horizontal)
            .padding(.bottom, 40.0)

        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .navigationTitle("Add Channel")
        .navigationBarTitleDisplayMode(.inline)
        .padding()
        .focused($isFocused)
        .onAppear {
            viewModel.getColor()
        }
        .onReceive(viewModel.$channelAddViewError) { errorMessage in
            if errorMessage != nil {
                showingChannelAddViewErrorAlert = true
            }
        }
        .onReceive(viewModel.$isOpenChannelFinished) { _ in }
        .alert(isPresented: $showingChannelAddViewErrorAlert) {
            Alert(
                title: Text(viewModel.channelAddViewError?.title ?? "Unknown"),
                message: Text(viewModel.channelAddViewError?.detail ?? ""),
                dismissButton: .default(Text("OK")) {
                    viewModel.channelAddViewError = nil
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

extension ChannelAddView {

    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let result):
            let scannedQRCode = result.string.lowercased()
            if let peer = scannedQRCode.parseConnectionInfo() {
                viewModel.nodeId = peer.nodeID
                viewModel.address = peer.address
            } else {
                viewModel.channelAddViewError = .init(
                    title: "QR Parsing Error",
                    detail: "Failed to parse the QR code."
                )
            }
        case .failure(let error):
            viewModel.channelAddViewError = .init(
                title: "Scan Error",
                detail: error.localizedDescription
            )
        }
    }

}

#if DEBUG
    #Preview {
        ChannelAddView(viewModel: .init())
    }
#endif
