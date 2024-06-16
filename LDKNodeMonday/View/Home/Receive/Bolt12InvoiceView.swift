//
//  Bolt12InvoiceView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 6/1/24.
//

import BitcoinUI
import LDKNode
import SwiftUI

struct Bolt12InvoiceView: View {
    @ObservedObject var viewModel: Bolt12InvoiceViewModel
    @State private var isCopied = false
    @State private var showCheckmark = false
    @State private var showingReceiveViewErrorAlert = false
    @State private var isKeyboardVisible = false

    var body: some View {

        VStack {

            if viewModel.invoice == "" {

                VStack(alignment: .leading) {

                    Text("Sats")
                        .bold()
                        .padding(.horizontal)

                    ZStack {
                        TextField(
                            "0",
                            text: $viewModel.amountMsat
                        )
                        .keyboardType(.numberPad)
                        .submitLabel(.done)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 32))

                        if !viewModel.amountMsat.isEmpty {
                            HStack {
                                Spacer()
                                Button {
                                    self.viewModel.amountMsat = ""
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
                        let amountMsat = (UInt64(viewModel.amountMsat) ?? 0) * 1000
                        await viewModel.receivePayment(
                            amountMsat: amountMsat,
                            description: "Monday Wallet"
                        )
                    }
                } label: {
                    Text("Create Amount Invoice")
                }

            } else {

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

#Preview {
    Bolt12InvoiceView(viewModel: .init())
}
