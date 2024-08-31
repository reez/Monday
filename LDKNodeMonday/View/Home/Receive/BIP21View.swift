//
//  BIP21View.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 7/19/24.
//

import BitcoinUI
import LDKNode
import SwiftUI

struct BIP21View: View {
    @ObservedObject var viewModel: BIP21ViewModel
    @State private var onchainIsCopied = false
    @State private var onchainShowCheckmark = false
    @State private var bolt11IsCopied = false
    @State private var bolt11ShowCheckmark = false
    @State private var bolt12IsCopied = false
    @State private var bolt12ShowCheckmark = false
    @State private var unifiedIsCopied = false
    @State private var unifiedShowCheckmark = false
    @State private var showingReceiveViewErrorAlert = false
    @State private var showingAmountEntryView = false
    @State private var isLoadingQR = true

    var body: some View {

        VStack {

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondary.opacity(0.2))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        ProgressView()
                    )
                    .opacity(isLoadingQR ? 1 : 0)

                if !isLoadingQR {
                    QRCodeView(qrCodeType: .bip21(viewModel.unified))
                        .opacity(1)
                        .transition(.opacity)
                        .animation(.easeInOut, value: isLoadingQR)
                }
            }
            .onAppear {
                Task {
                    await generateUnifiedQR()
                }
            }

            Spacer()

            VStack(spacing: 5.0) {

                if let components = parseUnifiedQR(viewModel.unified) {

                    VStack {
                        Text("\(viewModel.amountSat.formattedAmount()) Sats")
                            .bold()
                            .font(.title)

                        Button("Update Amount") {
                            showingAmountEntryView = true
                        }
                        .tint(viewModel.networkColor)
                        .font(.caption)
                        .sheet(isPresented: $showingAmountEntryView) {
                            AmountEntryView(amount: $viewModel.amountSat)
                        }
                    }
                    .padding()

                    InvoiceRowView(
                        title: "Unified",
                        value: viewModel.unified,
                        isCopied: unifiedIsCopied,
                        showCheckmark: unifiedShowCheckmark,
                        networkColor: viewModel.networkColor
                    ) {
                        copyToClipboard(
                            text: viewModel.unified,
                            isCopied: $unifiedIsCopied,
                            showCheckmark: $unifiedShowCheckmark
                        )
                    }

                    InvoiceRowView(
                        title: "On Chain",
                        value: components.onchain,
                        isCopied: onchainIsCopied,
                        showCheckmark: onchainShowCheckmark,
                        networkColor: viewModel.networkColor
                    ) {
                        copyToClipboard(
                            text: components.onchain,
                            isCopied: $onchainIsCopied,
                            showCheckmark: $onchainShowCheckmark
                        )
                    }

                    InvoiceRowView(
                        title: "BOLT 11",
                        value: components.bolt11,
                        isCopied: bolt11IsCopied,
                        showCheckmark: bolt11ShowCheckmark,
                        networkColor: viewModel.networkColor
                    ) {
                        copyToClipboard(
                            text: components.bolt11,
                            isCopied: $bolt11IsCopied,
                            showCheckmark: $bolt11ShowCheckmark
                        )
                    }

                    InvoiceRowView(
                        title: "BOLT 12",
                        value: components.bolt12,
                        isCopied: bolt12IsCopied,
                        showCheckmark: bolt12ShowCheckmark,
                        networkColor: viewModel.networkColor
                    ) {
                        copyToClipboard(
                            text: components.bolt12,
                            isCopied: $bolt12IsCopied,
                            showCheckmark: $bolt12ShowCheckmark
                        )
                    }

                    Button("Clear Invoice") {
                        viewModel.clearInvoice()
                    }
                    .font(.caption)
                    .tint(viewModel.networkColor)
                    .padding()

                }

            }

        }
        .onAppear {
            viewModel.getColor()
        }
        .onChange(of: viewModel.amountSat) { oldValue, newValue in
            Task {
                await generateUnifiedQR()
            }
        }
        .onReceive(viewModel.$receiveViewError) { errorMessage in
            if errorMessage != nil {
                showingReceiveViewErrorAlert = true
            }
        }
        .alert(isPresented: $showingReceiveViewErrorAlert) {
            Alert(
                title: Text(viewModel.receiveViewError?.title ?? "Unknown"),
                message: Text(viewModel.receiveViewError?.detail ?? ""),
                dismissButton: .default(Text("OK")) {
                    viewModel.receiveViewError = nil
                }
            )
        }

    }

    private func generateUnifiedQR() async {
        isLoadingQR = true
        let amountSat = (UInt64(viewModel.amountSat) ?? 0)
        await viewModel.receivePayment(
            amountSat: amountSat,
            message: "Monday Wallet",
            expirySecs: UInt32(3600)
        )
        isLoadingQR = false
    }

    private func copyToClipboard(
        text: String,
        isCopied: Binding<Bool>,
        showCheckmark: Binding<Bool>
    ) {
        UIPasteboard.general.string = text
        isCopied.wrappedValue = true
        showCheckmark.wrappedValue = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isCopied.wrappedValue = false
            showCheckmark.wrappedValue = false
        }
    }

}

struct InvoiceRowView: View {
    let title: String
    let value: String
    let isCopied: Bool
    let showCheckmark: Bool
    let networkColor: Color
    let onCopy: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 5.0) {
                Text(title)
                    .bold()
                Text(value)
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
                    .redacted(reason: value.isEmpty ? .placeholder : [])
            }
            .font(.caption2)

            Spacer()

            Button(action: onCopy) {
                HStack {
                    withAnimation {
                        Image(systemName: showCheckmark ? "checkmark" : "doc.on.doc")
                            .font(.title3)
                            .minimumScaleFactor(0.5)
                    }
                }
                .bold()
                .foregroundColor(networkColor)
            }
            .font(.caption2)
        }
        .padding(.horizontal)
    }
}

struct UnifiedQRComponents {
    let onchain: String
    let bolt11: String
    let bolt12: String
}

func parseUnifiedQR(_ unifiedQR: String) -> UnifiedQRComponents? {
    // Split the string by '?'
    let components = unifiedQR.components(separatedBy: "?")

    guard components.count > 1 else { return nil }

    // Extract onchain (everything before the first '?') and remove the "BITCOIN:" prefix
    var onchain = components[0]
    if onchain.lowercased().hasPrefix("bitcoin:") {
        onchain = String(onchain.dropFirst(8))  // Remove "BITCOIN:"
    }

    // Join the rest of the components back together
    let remainingString = components.dropFirst().joined(separator: "?")

    // Split the remaining string by '&'
    let params = remainingString.components(separatedBy: "&")

    var bolt11: String?
    var bolt12: String?

    for param in params {
        if param.starts(with: "lightning=") {
            bolt11 = String(param.dropFirst("lightning=".count))
        } else if param.starts(with: "lno=") {
            bolt12 = String(param.dropFirst("lno=".count))
        }
    }

    guard let bolt11 = bolt11, let bolt12 = bolt12 else { return nil }

    return UnifiedQRComponents(onchain: onchain, bolt11: bolt11, bolt12: bolt12)
}

#Preview {
    BIP21View(viewModel: .init())
}
