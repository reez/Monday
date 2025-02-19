//
//  ReceiveView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/25/24.
//

import BitcoinUI
import SwiftUI

struct ReceiveView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ReceiveViewModel
    @State var showCopyDialog = false
    @State var copied = false

    var body: some View {

        NavigationView {
            VStack {
                if viewModel.paymentAddresses.count > 0 {

                    // QR Code
                    GeometryReader { geometry in
                        TabView {
                            ForEach(viewModel.paymentAddresses.compactMap { $0 }, id: \.address) {
                                paymentAddress in
                                QRView(paymentAddress: paymentAddress)
                                    .padding(40)
                            }
                        }
                        .frame(height: geometry.size.width * 1.1)
                        .tabViewStyle(.page(indexDisplayMode: .always))
                        .indexViewStyle(.page(backgroundDisplayMode: .always))
                    }

                    // Share Button
                    Button {
                        //
                    } label: {
                        ShareLink(
                            item: viewModel.paymentAddresses
                                .compactMap({ $0 })
                                .first(where: { $0.type == .bip21 })?.address ?? "",
                            preview: SharePreview(
                                "Bitcoin address, BIP21 format",
                                image: Image("AppIcon")
                            )
                        ) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }
                    .buttonStyle(
                        BitcoinFilled(
                            tintColor: .accent,
                            isCapsule: true
                        )
                    )

                    // Copy Button and Confirmation Dialog
                    Button {
                        self.showCopyDialog = true
                    } label: {
                        Label(copied ? "Copied" : "Copy", systemImage: "document.on.document")
                    }
                    .disabled(copied)
                    .buttonStyle(
                        BitcoinPlain(
                            tintColor: .accent
                        )
                    )
                    .confirmationDialog(
                        "Copy Bitcoin Address",
                        isPresented: $showCopyDialog,
                        titleVisibility: .visible
                    ) {
                        ForEach(viewModel.paymentAddresses.compactMap { $0 }, id: \.address) {
                            paymentAddress in
                            Button(paymentAddress.description) {
                                UIPasteboard.general.string = paymentAddress.address
                                self.copied = true
                            }
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .padding(.bottom, 20)
            .navigationTitle("Receive Bitcoin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.generateUnifiedQR()
                }
            }
        }
    }
}

struct AmountEntryView: View {
    @Binding var amount: String
    @Environment(\.dismiss) private var dismiss

    @State private var numpadAmount = "0"

    var body: some View {
        VStack(spacing: 20) {

            Spacer()

            Text("\(numpadAmount.formattedAmount(defaultValue: "0")) sats")
                .textStyle(BitcoinTitle1())
                .padding()

            GeometryReader { geometry in
                let buttonSize = geometry.size.width / 4
                VStack(spacing: buttonSize / 10) {
                    numpadRow(["1", "2", "3"], buttonSize: buttonSize)
                    numpadRow(["4", "5", "6"], buttonSize: buttonSize)
                    numpadRow(["7", "8", "9"], buttonSize: buttonSize)
                    numpadRow([" ", "0", "<"], buttonSize: buttonSize)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: 300)

            Spacer()

            Button {
                amount = numpadAmount
                dismiss()
            } label: {
                HStack(spacing: 1) {
                    Text("Confirm")
                        .padding(.horizontal, 40)
                        .padding(.vertical, 5)
                }
                .foregroundColor(Color(uiColor: UIColor.systemBackground))
                .bold()
            }
            .buttonBorderShape(.capsule)
            .buttonStyle(.borderedProminent)
            .tint(.primary)

        }
        .padding()
    }

    func numpadRow(_ characters: [String], buttonSize: CGFloat) -> some View {
        HStack(spacing: buttonSize / 2) {
            ForEach(characters, id: \.self) { character in
                NumpadButton(numpadAmount: $numpadAmount, character: character)
                    .frame(width: buttonSize, height: buttonSize / 1.5)
            }
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

#if DEBUG
    #Preview {
        ReceiveView(viewModel: ReceiveViewModel(lightningClient: .mock))
        //AmountEntryView(amount: .constant("21"))
    }
#endif
