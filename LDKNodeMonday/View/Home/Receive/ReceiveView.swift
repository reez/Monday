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
    @State private var selectedTabIndex: Int = 0
    @State private var favoriteColor = 0
    @State var showCopyDialog = false
    @State var copied = false

    var body: some View {

        NavigationView {
            VStack {
                if viewModel.paymentAddresses.count > 0 {

                    // QR Code
                    GeometryReader { geometry in

                        TabView(selection: $selectedTabIndex) {
                            ForEach(
                                Array(viewModel.paymentAddresses.compactMap { $0 }.enumerated()),
                                id: \.element.address
                            ) { index, paymentAddress in
                                VStack {
                                    QRView(paymentAddress: paymentAddress)
                                        .padding(.horizontal, 50)

                                    switch paymentAddress.type {
                                    case .bip21:
                                        VStack {
                                            ForEach(
                                                viewModel.paymentAddresses.compactMap { $0 },
                                                id: \.address
                                            ) { paymentAddress in
                                                PaymentAddressView(
                                                    paymentAddress: paymentAddress,
                                                    copied: $copied
                                                )
                                                .padding(.horizontal, 60)
                                            }
                                        }
                                    default:
                                        PaymentAddressView(
                                            paymentAddress: paymentAddress,
                                            copied: $copied
                                        )
                                        .padding(.horizontal, 60)
                                    }
                                }
                                .tag(index)
                            }
                        }
                        //.frame(height: geometry.size.width)
                        .tabViewStyle(.page(indexDisplayMode: .always))
                        .indexViewStyle(.page(backgroundDisplayMode: .always))
                        .onChange(of: selectedTabIndex) {
                            self.copied = false
                        }
                    }

                    HStack {
                        // Add amount Button
                        Button {
                            //
                        } label: {
                            Label("Add amount", systemImage: "plus")
                        }
                        .buttonStyle(
                            BitcoinOutlined(
                                width: 150,
                                tintColor: .accent,
                                isCapsule: true
                            )
                        )

                        Spacer()

                        // Share Button
                        Button {
                            //
                        } label: {
                            ShareLink(
                                item: currentPaymentAddress?.address ?? "No address",
                                preview: SharePreview(
                                    currentPaymentAddress?.description ?? "No description",
                                    image: Image("AppIcon")
                                )
                            ) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                        }
                        .buttonStyle(
                            BitcoinFilled(
                                width: 150,
                                tintColor: .accent,
                                isCapsule: true
                            )
                        )
                    }.padding(.horizontal, 40)
                } else {
                    ProgressView()
                }
                // TODO: Handle state where no address is generated / error
            }
            .padding(.bottom, 20)
            .navigationTitle(currentPaymentAddress?.title ?? "Receive Bitcoin")
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

    var currentPaymentAddress: PaymentAddress? {
        if viewModel.paymentAddresses.indices.contains(selectedTabIndex) {
            return viewModel.paymentAddresses[selectedTabIndex]
        }
        return nil
    }
}

struct PaymentAddressView: View {
    var paymentAddress: PaymentAddress
    @Binding var copied: Bool

    var body: some View {
        HStack {
            Text(paymentAddress.description)
                .font(.caption)
            Spacer()
            Text(paymentAddress.address.lowercased())
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 100)
                .lineLimit(1)
                .truncationMode(.middle)
            Button {
                UIPasteboard.general.string = paymentAddress.address
                copied = true
            } label: {
                Image(systemName: copied ? "checkmark" : "doc.on.doc")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .foregroundColor(copied ? .secondary : .accentColor)
                    .accessibilityLabel(copied ? "Copied" : "Copy node ID")
            }
        }
        .frame(height: 20)
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
