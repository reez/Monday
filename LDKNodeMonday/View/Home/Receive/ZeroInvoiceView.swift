//
//  ZeroInvoiceView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/29/24.
//

import BitcoinUI
import LDKNode
import SwiftUI

struct ZeroInvoiceView: View {
    @ObservedObject var viewModel: ZeroAmountViewModel
    @State private var isCopied = false
    @State private var showCheckmark = false
    @State private var showingReceiveViewErrorAlert = false
    @State private var isKeyboardVisible = false

    var body: some View {

        VStack {

            QRCodeView(qrCodeType: .lightning(viewModel.invoice))

            VStack {

                HStack(alignment: .center) {

                    VStack(alignment: .leading, spacing: 5.0) {
                        HStack {
                            Text("Lightning Network")
                                .font(.caption)
                                .bold()
                        }
                        Text(viewModel.invoice)
                            .font(.caption)
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                            .redacted(
                                reason: viewModel.invoice.isEmpty ? .placeholder : []
                            )
                    }

                    Spacer()

                    Button {
                        UIPasteboard.general.string = viewModel.invoice
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
                                .font(.title2)
                                .minimumScaleFactor(0.5)
                            }
                        }
                        .bold()
                        .foregroundColor(viewModel.networkColor)
                    }

                }
                .padding()

            }

        }
        .onAppear {
            Task {
                await viewModel.receiveVariableAmountPayment(
                    description: "Monday Wallet",
                    expirySecs: UInt32(3600)
                )
                viewModel.getColor()
            }
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

#Preview {
    ZeroInvoiceView(viewModel: .init())
}
