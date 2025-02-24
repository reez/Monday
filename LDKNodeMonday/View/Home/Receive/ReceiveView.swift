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
    @State private var selectedAddressIndex: Int = 0
    @State private var favoriteColor = 0
    @State var showCopyDialog = false
    @State var copied = false
    @State private var isExpanded = false

    var body: some View {

        NavigationView {
            VStack {
                if viewModel.paymentAddresses.count > 0 {

                    Spacer()

                    VStack {
                        // QR Code
                        QRView(paymentAddress: selectedPaymentAddress)
                            .padding(.horizontal, 50)
                        HStack {
                            HStack {
                                Text(selectedPaymentAddress?.description ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Button {
                                    UIPasteboard.general.string = selectedPaymentAddress?.address
                                    withAnimation {
                                        copied = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation {
                                            copied = false
                                        }
                                    }
                                } label: {
                                    Image(
                                        systemName: copied
                                            ? "checkmark" : "doc.on.doc"
                                    )
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(
                                        copied ? .secondary : .accentColor
                                    )
                                    .accessibilityLabel(
                                        copied ? "Copied" : "Copy"
                                    )
                                    .animation(.spring(), value: copied)
                                }
                            }
                            Spacer()
                            Button {
                                isExpanded.toggle()
                            } label: {
                                HStack {
                                    Text("Show all")
                                    Image(systemName: "chevron.right")
                                        .font(.subheadline.bold())
                                }
                                .font(.subheadline)
                                .foregroundColor(.accentColor)
                            }
                            .sheet(isPresented: $isExpanded) {
                                NavigationStack {
                                    let addressArray = Array(
                                        viewModel.paymentAddresses.compactMap { $0 }
                                            .enumerated()
                                    )
                                    Form {
                                        Picker("Address Type", selection: $selectedAddressIndex) {
                                            ForEach(
                                                addressArray,
                                                id: \.element.address
                                            ) { index, address in
                                                let isSelected =
                                                    address.type == selectedPaymentAddress?.type

                                                HStack {
                                                    Label(
                                                        address.description,
                                                        systemImage: isSelected
                                                            ? "qrcode" : "doc.on.doc"
                                                    )
                                                    .labelStyle(.titleOnly)

                                                    Spacer()

                                                    Text(address.address.lowercased())
                                                        .font(.caption)
                                                        .frame(width: 100)
                                                        .truncationMode(.middle)
                                                        .lineLimit(1)
                                                        .foregroundColor(.secondary)
                                                }.tag(index)
                                            }
                                        }
                                        .pickerStyle(.inline)
                                        .onChange(of: selectedAddressIndex) {
                                            isExpanded = false
                                        }
                                    }
                                    .presentationDetents([
                                        .height(CGFloat(50 + addressArray.count * 45))
                                    ])
                                }
                            }
                        }.padding(.horizontal, 55)
                    }
                }

                Spacer()

                HStack {
                    // Add amount Button
                    Button {
                        //
                    } label: {
                        Label("Amount", systemImage: "plus")
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
                            item: selectedPaymentAddress?.address ?? "No address",
                            preview: SharePreview(
                                selectedPaymentAddress?.description ?? "No description",
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
            }
            .padding(.bottom, 20)
            .navigationTitle(selectedPaymentAddress?.title ?? "Receive Bitcoin")
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
            //            else {
            //                    ProgressView()
            //                }
            // TODO: Handle state where no address is generated / error
        }

    }

    var selectedPaymentAddress: PaymentAddress? {
        if viewModel.paymentAddresses.indices.contains(selectedAddressIndex) {
            return viewModel.paymentAddresses[selectedAddressIndex]
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
                .font(.subheadline.bold())
            Spacer()
            Text(paymentAddress.address.lowercased())
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
                    .frame(width: 16, height: 16)
                    .foregroundColor(copied ? .secondary : .accentColor)
                    .accessibilityLabel(copied ? "Copied" : "Copy node ID")
            }
        }
        .frame(height: 24)
        .font(.subheadline)
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

#if DEBUG
    #Preview {
        ReceiveView(viewModel: ReceiveViewModel(lightningClient: .mock))
        //AmountEntryView(amount: .constant("21"))
    }
#endif
