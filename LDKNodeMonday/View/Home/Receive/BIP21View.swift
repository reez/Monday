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
    @State private var isKeyboardVisible = false

    var body: some View {

        VStack {

            if viewModel.unified == "" {

                VStack(alignment: .leading) {

                    Text("Sats")
                        .bold()
                        .padding(.horizontal)

                    ZStack {
                        TextField(
                            "0",
                            text: $viewModel.amountSat
                        )
                        .keyboardType(.numberPad)
                        .submitLabel(.done)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 32))

                        if !viewModel.amountSat.isEmpty {
                            HStack {
                                Spacer()
                                Button {
                                    self.viewModel.amountSat = ""
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

                Button {
                    Task {
                        let amountSat = (UInt64(viewModel.amountSat) ?? 0)
                        await viewModel.receivePayment(
                            amountSat: amountSat,
                            message: "Monday Wallet",
                            expirySecs: UInt32(3600)
                        )
                    }
                } label: {
                    Text("Create Unified QR")
                }

            } else {

                QRCodeView(qrCodeType: .bip21(viewModel.unified))

                VStack(spacing: 5.0) {

                    HStack(alignment: .center) {

                        VStack(alignment: .leading, spacing: 5.0) {
                            Text("Unified")
                                .bold()
                            Text(viewModel.unified)
                                .truncationMode(.middle)
                                .lineLimit(1)
                                .foregroundColor(.secondary)
                                .redacted(
                                    reason: viewModel.unified.isEmpty ? .placeholder : []
                                )
                        }
                        .font(.caption2)

                        Spacer()

                        Button {
                            UIPasteboard.general.string = viewModel.unified
                            unifiedIsCopied = true
                            unifiedShowCheckmark = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                unifiedIsCopied = false
                                unifiedShowCheckmark = false
                            }
                        } label: {
                            HStack {
                                withAnimation {
                                    Image(
                                        systemName: unifiedShowCheckmark
                                            ? "checkmark" : "doc.on.doc"
                                    )
                                    .font(.title3)
                                    .minimumScaleFactor(0.5)
                                }
                            }
                            .bold()
                            .foregroundColor(viewModel.networkColor)
                        }
                        .font(.caption2)

                    }
                    .padding(.horizontal)

                    HStack(alignment: .center) {

                        VStack(alignment: .leading, spacing: 5.0) {
                            Text("On Chain")
                                .bold()
                            if let components = parseUnifiedQR(viewModel.unified) {
                                Text(components.onchain)
                                    .truncationMode(.middle)
                                    .lineLimit(1)
                                    .foregroundColor(.secondary)
                                    .redacted(
                                        reason: viewModel.unified.isEmpty ? .placeholder : []
                                    )
                            }
                        }
                        .font(.caption2)

                        Spacer()

                        if let components = parseUnifiedQR(viewModel.unified) {
                            Button {
                                UIPasteboard.general.string = components.onchain
                                onchainIsCopied = true
                                onchainShowCheckmark = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    onchainIsCopied = false
                                    onchainShowCheckmark = false
                                }
                            } label: {
                                HStack {
                                    withAnimation {
                                        Image(
                                            systemName: onchainShowCheckmark
                                                ? "checkmark" : "doc.on.doc"
                                        )
                                        .font(.title3)
                                        .minimumScaleFactor(0.5)
                                    }
                                }
                                .bold()
                                .foregroundColor(viewModel.networkColor)
                            }
                            .font(.caption2)

                        }

                    }
                    .padding(.horizontal)

                    HStack(alignment: .center) {

                        VStack(alignment: .leading, spacing: 5.0) {
                            Text("BOLT 11")
                                .bold()
                            if let components = parseUnifiedQR(viewModel.unified) {
                                Text(components.bolt11)
                                    .truncationMode(.middle)
                                    .lineLimit(1)
                                    .foregroundColor(.secondary)
                                    .redacted(
                                        reason: viewModel.unified.isEmpty ? .placeholder : []
                                    )
                            }
                        }
                        .font(.caption2)

                        Spacer()

                        if let components = parseUnifiedQR(viewModel.unified) {
                            Button {
                                UIPasteboard.general.string = components.bolt11
                                bolt11IsCopied = true
                                bolt11ShowCheckmark = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    bolt11IsCopied = false
                                    bolt11ShowCheckmark = false
                                }
                            } label: {
                                HStack {
                                    withAnimation {
                                        Image(
                                            systemName: bolt11ShowCheckmark
                                                ? "checkmark" : "doc.on.doc"
                                        )
                                        .font(.title3)
                                        .minimumScaleFactor(0.5)
                                    }
                                }
                                .bold()
                                .foregroundColor(viewModel.networkColor)
                            }
                            .font(.caption2)

                        }

                    }
                    .padding(.horizontal)

                    HStack(alignment: .center) {

                        VStack(alignment: .leading, spacing: 5.0) {
                            Text("BOLT12")
                                .bold()
                            if let components = parseUnifiedQR(viewModel.unified) {
                                Text(components.bolt12)
                                    .truncationMode(.middle)
                                    .lineLimit(1)
                                    .foregroundColor(.secondary)
                                    .redacted(
                                        reason: viewModel.unified.isEmpty ? .placeholder : []
                                    )
                            }
                        }
                        .font(.caption2)

                        Spacer()

                        if let components = parseUnifiedQR(viewModel.unified) {
                            Button {
                                UIPasteboard.general.string = components.bolt12
                                bolt12IsCopied = true
                                bolt12ShowCheckmark = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    bolt12IsCopied = false
                                    bolt12ShowCheckmark = false
                                }
                            } label: {
                                HStack {
                                    withAnimation {
                                        Image(
                                            systemName: bolt12ShowCheckmark
                                                ? "checkmark" : "doc.on.doc"
                                        )
                                        .font(.title3)
                                        .minimumScaleFactor(0.5)
                                    }
                                }
                                .bold()
                                .foregroundColor(viewModel.networkColor)
                            }
                            .font(.caption2)

                        }

                    }
                    .padding(.horizontal)

                    Button("Clear Invoice") {
                        viewModel.clearInvoice()
                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.bordered)
                    .tint(viewModel.networkColor)
                    .padding()

                }

            }

        }
        .onAppear {
            viewModel.getColor()
        }
        .onReceive(viewModel.$receiveViewError) { errorMessage in
            if errorMessage != nil {
                showingReceiveViewErrorAlert = true
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIResponder.keyboardWillShowNotification
            )
        ) { _ in
            isKeyboardVisible = true
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIResponder.keyboardWillHideNotification
            )
        ) { _ in
            isKeyboardVisible = false
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
