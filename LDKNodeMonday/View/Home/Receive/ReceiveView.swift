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
                Spacer()
                if viewModel.receiveViewError != nil {
                    // Show message if error
                    VStack {
                        Text(viewModel.receiveViewError?.title ?? "Error")
                        Text(viewModel.receiveViewError?.detail ?? "Unknown error")
                    }
                    .padding(40)
                } else if viewModel.addressGenerationFinished == false {
                    // Show progress indicator while generating addresses
                    ProgressView()
                } else if viewModel.paymentAddresses.count > 0 {
                    // Show QR code and address info
                    AddressInfoView(
                        isExpanded: $isExpanded,
                        selectedAddressIndex: $selectedAddressIndex,
                        copied: $copied,
                        selectedPaymentAddress: selectedPaymentAddress,
                        addressArray: viewModel.paymentAddresses.compactMap { $0 }
                    )
                }

                Spacer()

                (viewModel.receiveViewError == nil)
                    ? ReceiveActionButtons(selectedPaymentAddress: selectedPaymentAddress) : nil
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
                    await viewModel.generateAddresses()
                }
            }
        }

    }

    var selectedPaymentAddress: PaymentAddress? {
        if viewModel.paymentAddresses.indices.contains(selectedAddressIndex) {
            return viewModel.paymentAddresses[selectedAddressIndex]
        }
        return nil
    }
}

struct AddressInfoView: View {
    @Binding var isExpanded: Bool
    @Binding var selectedAddressIndex: Int
    @Binding var copied: Bool
    var selectedPaymentAddress: PaymentAddress?
    var addressArray: [PaymentAddress]

    var body: some View {
        VStack {
            // QR Code and Address Information
            QRView(paymentAddress: selectedPaymentAddress)
                .padding(.horizontal, 50)

            HStack {
                // Address Description and Copy Button
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
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(copied ? .secondary : .accentColor)
                            .accessibilityLabel(copied ? "Copied" : "Copy")
                            .animation(.spring(), value: copied)
                    }
                }

                Spacer()

                // "Show all" Button
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
                    AddressPickerSheet(
                        isExpanded: $isExpanded,
                        selectedAddressIndex: $selectedAddressIndex,
                        addressArray: addressArray,
                        selectedPaymentAddress: selectedPaymentAddress
                    )
                }
            }
            .padding(.horizontal, 55)
        }
    }
}

struct AddressPickerSheet: View {
    @Binding var isExpanded: Bool
    @Binding var selectedAddressIndex: Int
    var addressArray: [PaymentAddress]
    var selectedPaymentAddress: PaymentAddress?

    var body: some View {
        NavigationStack {
            Form {
                Picker("Address Type", selection: $selectedAddressIndex) {
                    ForEach(Array(addressArray.enumerated()), id: \.element.address) {
                        index,
                        address in
                        HStack {
                            Label(
                                address.description,
                                systemImage: address.type == selectedPaymentAddress?.type
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
                        }
                        .tag(index)  // Use the index here instead of looking up the index
                    }
                }
                .pickerStyle(.inline)
                .onChange(of: selectedAddressIndex) {
                    isExpanded = false
                }
            }
            .presentationDetents([.height(CGFloat(50 + addressArray.count * 45))])
        }
    }
}

struct ReceiveActionButtons: View {
    var selectedPaymentAddress: PaymentAddress?

    var body: some View {
        HStack {
            // Add amount Button
            Button {
                // Action for adding amount
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

            // Share Button
            Button {
                // Action for sharing
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

#if DEBUG
    #Preview {
        ReceiveView(viewModel: ReceiveViewModel(lightningClient: .mock))
        //AmountEntryView(amount: .constant("21"))
    }
#endif
