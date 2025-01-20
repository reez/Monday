//
//  JITInvoiceView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/29/24.
//

import BitcoinUI
import LDKNode
import SwiftUI

struct JITInvoiceView: View {
    @ObservedObject var viewModel: JITInvoiceViewModel
    @State private var isCopied = false
    @State private var showCheckmark = false
    @State private var showingReceiveViewErrorAlert = false
    @State private var isKeyboardVisible = false
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
                    QRCodeView(qrCodeType: .lightning(viewModel.invoice))
                        .opacity(1)
                        .transition(.opacity)
                        .animation(.easeInOut, value: isLoadingQR)
                }
            }
            .onAppear {
                Task {
                    isLoadingQR = true
                    let amountMsat = (UInt64(viewModel.amountMsat) ?? 0) * 1000
                    await viewModel.receivePaymentViaJitChannel(
                        amountMsat: amountMsat,
                        description: "Monday Wallet",
                        expirySecs: UInt32(3600),
                        maxLspFeeLimitMsat: nil
                    )
                    isLoadingQR = false
                }

            }

        }

        Spacer()

        VStack {

            if viewModel.invoice != "" {

                VStack {
                    Text("\(viewModel.amountMsat.formattedAmount()) sats")
                        .bold()
                        .font(.title)

                    Button("Update Amount") {
                        showingAmountEntryView = true
                    }
                    .tint(viewModel.networkColor)
                    .font(.caption)
                    .sheet(isPresented: $showingAmountEntryView) {
                        AmountEntryView(amount: $viewModel.amountMsat)
                    }
                }
                .padding()

                InvoiceRowView(
                    title: "JIT Invoice",
                    value: viewModel.invoice,
                    isCopied: isCopied,
                    showCheckmark: showCheckmark,
                    networkColor: viewModel.networkColor
                ) {
                    copyToClipboard(
                        text: viewModel.invoice,
                        isCopied: $isCopied,
                        showCheckmark: $showCheckmark
                    )
                }

            }
        }
        .padding()
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

#if DEBUG
    #Preview {
        JITInvoiceView(viewModel: .init(lightningClient: .mock))
    }
#endif
