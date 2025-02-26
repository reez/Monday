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
    @State var showShareDialog = false
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
                } else if viewModel.addressGenerationStatus == .generating {
                    // Show progress indicator while generating addresses
                    ProgressView()
                } else if viewModel.paymentAddresses.count > 0 {
                    // Show QR code and address info
                    AddressInfoView(
                        isExpanded: $isExpanded,
                        selectedAddressIndex: $selectedAddressIndex,
                        selectedPaymentAddress: selectedPaymentAddress,
                        addressArray: viewModel.paymentAddresses.compactMap { $0 }
                    )
                }

                Spacer()

                if viewModel.receiveViewError == nil {
                    ReceiveActionButtons(
                        selectedPaymentAddress: selectedPaymentAddress,
                        viewModel: viewModel
                    )
                }

            }
            .padding(.bottom, 20)
            .dynamicTypeSize(...DynamicTypeSize.accessibility2)  // Sets max dynamic size for all Text
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
    @State var showQRFullScreen = false
    var selectedPaymentAddress: PaymentAddress?
    var addressArray: [PaymentAddress]

    var body: some View {
        VStack {
            // QR Code and Address Information
            QRView(paymentAddress: selectedPaymentAddress)
                .onTapGesture {
                    withAnimation(
                        .interpolatingSpring,
                        {
                            showQRFullScreen.toggle()
                        }
                    )
                }

            HStack {
                // Address Description
                Text(selectedPaymentAddress?.description ?? "")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Button {
                    withAnimation(
                        .interpolatingSpring,
                        {
                            showQRFullScreen.toggle()
                        }
                    )
                } label: {
                    Image(systemName: "rectangle.expand.diagonal")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .font(.subheadline.bold())
                        .foregroundColor(.accentColor)
                        .accessibilityLabel("QR code fullscreen")
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

        }.padding(.horizontal, showQRFullScreen ? 5 : 50)
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
    @ObservedObject var viewModel: ReceiveViewModel
    @State var showAmountEntryView = false
    @State var copied = false

    var body: some View {
        VStack {
            // Add amount Button
            Button {
                showAmountEntryView.toggle()
            } label: {
                if viewModel.amountSat == UInt64(0) {
                    Label("Add Amount", systemImage: "plus")
                } else {
                    Text(
                        (Int(viewModel.amountSat).formatted(.number.notation(.automatic))) + " sats"
                    )
                }
            }
            .padding(.vertical, 10)
            .buttonStyle(
                BitcoinOutlined(
                    tintColor: .accent,
                    isCapsule: true
                )
            )
            .sheet(
                isPresented: $showAmountEntryView,
                content: {
                    AmountEntryView(amount: $viewModel.amountSat)
                }
            )
            .onChange(of: showAmountEntryView) { _, newValue in
                if newValue == false {
                    Task {
                        await viewModel.generateAddresses()
                    }
                }
            }

            HStack {
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

                // Copy Button
                Button {
                    UIPasteboard.general.string = selectedPaymentAddress?.address
                    withAnimation {
                        copied = true
                    }
                } label: {
                    Label(
                        copied ? "Copied" : "Copy",
                        systemImage: copied ? "checkmark" : "doc.on.doc"
                    )
                }
                .buttonStyle(
                    BitcoinFilled(
                        width: 150,
                        tintColor: copied ? .secondary : .accent,
                        isCapsule: true
                    )
                )
            }
        }
        .onChange(of: selectedPaymentAddress) {
            copied = false
        }
        .onChange(of: viewModel.amountSat) {
            copied = false
        }
    }
}

#if DEBUG
    #Preview {
        ReceiveView(viewModel: ReceiveViewModel(lightningClient: .mock))
        //AmountEntryView(amount: .constant("21"))
    }
#endif
