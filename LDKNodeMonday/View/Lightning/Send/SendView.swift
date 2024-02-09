//
//  SendView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/28/23.
//

import BitcoinUI
import CodeScanner
import SwiftUI

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

                    HStack {

                        Button {
                            if pasteboard.hasStrings {
                                if let string = pasteboard.string {
                                    let lowercaseInvoice = string.lowercased()
                                    viewModel.invoice = lowercaseInvoice
                                } else {
                                    self.viewModel.parseError = .init(
                                        title: "Paste Parsing Error",
                                        detail: "Failed to parse the Pasteboard."
                                    )
                                }
                            } else {
                                self.viewModel.parseError = .init(
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

                        Text("Invoice")
                            .bold()
                            .padding(.horizontal)

                        ZStack {

                            TextField(
                                "lnbc10u1pwz...8f8r9ckzr0r",
                                text: $viewModel.invoice
                            )
                            .truncationMode(.middle)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 32))

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
                        .padding(.horizontal)

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
                            .bold()
                            .foregroundColor(Color(uiColor: UIColor.systemBackground))
                            .frame(maxWidth: .infinity)
                            .padding(.all, 8)
                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.borderedProminent)
                    .tint(viewModel.networkColor)
                    .frame(width: 300, height: 25)
                    .padding(.horizontal, 30.0)
                    .padding(.bottom, 40.0)

                    Spacer()

                }
                .padding()
                .sheet(isPresented: $isShowingScanner) {
                    CodeScannerView(
                        codeTypes: [.qr],
                        simulatedData:
                            "LNBC10U1P3PJ257PP5YZTKWJCZ5FTL5LAXKAV23ZMZEKAW37ZK6KMV80PK4XAEV5QHTZ7QDPDWD3XGER9WD5KWM36YPRX7U3QD36KUCMGYP282ETNV3SHJCQZPGXQYZ5VQSP5USYC4LK9CHSFP53KVCNVQ456GANH60D89REYKDNGSMTJ6YW3NHVQ9QYYSSQJCEWM5CJWZ4A6RFJX77C490YCED6PEMK0UPKXHY89CMM7SCT66K8GNEANWYKZGDRWRFJE69H9U5U0W57RRCSYSAS7GADWMZXC8C6T0SPJAZUP6",
                        completion: handleScan
                    )
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
            let scanString = result.string.lowercased()
            if scanString.hasPrefix("lightning:") {
                let invoice = scanString.replacingOccurrences(of: "lightning:", with: "")
                viewModel.invoice = invoice
            } else if scanString.hasPrefix("bitcoin:") {
                if let invoice = extractInvoiceFromBIP21(scanString) {
                    viewModel.invoice = invoice
                } else {
                    self.viewModel.parseError = .init(
                        title: "Scan Error",
                        detail: "Invalid BIP-21 format"
                    )
                }
            } else if let invoice = extractInvoiceFromScan(scanString) {
                viewModel.invoice = invoice
            } else {
                self.viewModel.parseError = .init(
                    title: "Scan Error",
                    detail: "Unsupported scan format"
                )
            }
        case .failure(let error):
            self.viewModel.parseError = .init(
                title: "Scan Error",
                detail: error.localizedDescription
            )
        }
    }

    private func extractInvoiceFromBIP21(_ scanString: String) -> String? {
        if let url = URL(string: scanString),
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems
        {
            for queryItem in queryItems {
                if queryItem.name.lowercased() == "lightning" {
                    return queryItem.value
                }
            }
        }
        return nil
    }

    private func extractInvoiceFromScan(_ scanString: String) -> String? {
        // testnet (lntb, lntbrt, lntbs), regtest (lnbcrt, lntbrt), and signet (lnbcs, lntbs)
        let prefixOptions = ["lnbc", "lntb", "lnbcrt", "lntbrt", "lnbcs", "lntbs"]
        for prefix in prefixOptions {
            if scanString.hasPrefix(prefix) {
                return scanString
            }
        }
        return nil
    }

}

struct SendView_Previews: PreviewProvider {
    static var previews: some View {
        SendView(viewModel: .init())
        SendView(viewModel: .init())
            .environment(\.sizeCategory, .accessibilityLarge)
        SendView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
