//
//  SendBitcoinView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 6/7/23.
//

import BitcoinUI
import CodeScanner
import SwiftUI

struct SendBitcoinView: View {
    @StateObject var viewModel: SendBitcoinViewModel
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

                    HStack {

                        Button {
                            if pasteboard.hasStrings {
                                if let string = pasteboard.string {
                                    let lowercaseAddress = string.lowercased()
                                    viewModel.address = lowercaseAddress
                                } else {
                                    self.viewModel.sendViewError = .init(
                                        title: "Paste Parsing Error",
                                        detail: "Failed to parse the Pasteboard."
                                    )
                                }
                            } else {
                                self.viewModel.sendViewError = .init(
                                    title: "Paste Parsing Error",
                                    detail: "Nothing found in the Pasteboard."
                                )
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
                        .padding()

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
                        .padding()

                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.bordered)
                    .tint(viewModel.networkColor)
                    .padding(.bottom)
                    .padding(.horizontal)

                    VStack(alignment: .leading) {

                        Text("Address")
                            .bold()
                            .padding(.horizontal)

                        ZStack {

                            TextField("1BvBMSEYstWet...m4GFg7xJaNVN2", text: $viewModel.address)
                                .truncationMode(.middle)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 32))

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
                        .padding(.horizontal)

                    }
                    .padding()

                    VStack {
                        if viewModel.txId.isEmpty {
                            Button {
                                Task {
                                    await viewModel.sendAllToOnchain(address: viewModel.address)
                                }
                            } label: {
                                Text("Send All")
                                    .bold()
                                    .foregroundColor(Color(uiColor: UIColor.systemBackground))
                                    .frame(maxWidth: .infinity)
                                    .padding(.all, 8)
                                    .lineLimit(1)
                            }
                            .buttonBorderShape(.capsule)
                            .buttonStyle(.borderedProminent)
                            .tint(viewModel.networkColor)
                            .frame(width: 200, height: 25)
                            .padding(.horizontal)
                            .padding(.horizontal)
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
                                                Image(
                                                    systemName: showCheckmark
                                                        ? "checkmark" : "doc.on.doc"
                                                )
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
                    .padding(.bottom, 40.0)

                    Spacer()

                }
                .padding()
                .sheet(isPresented: $isShowingScanner) {
                    CodeScannerView(
                        codeTypes: [.qr],
                        simulatedData: "1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2",
                        completion: handleScan
                    )
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
                self.viewModel.sendViewError = .init(
                    title: "No Address",
                    detail: "No Bitcoin Address found"
                )
            }
        case .failure(let error):
            self.viewModel.sendViewError = .init(
                title: "Scan Error",
                detail: error.localizedDescription
            )
        }
    }
}

struct SendBitcoinView_Previews: PreviewProvider {
    static var previews: some View {
        SendBitcoinView(viewModel: .init(spendableBalance: "1000000"))
        SendBitcoinView(viewModel: .init(spendableBalance: "1000000"))
            .environment(\.sizeCategory, .accessibilityLarge)
        SendBitcoinView(viewModel: .init(spendableBalance: "1010101"))
            .environment(\.colorScheme, .dark)
    }
}
