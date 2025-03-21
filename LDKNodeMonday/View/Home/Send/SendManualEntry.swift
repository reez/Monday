//
//  SendManualEntry.swift
//  LDKNodeMonday
//
//  Created by Daniel Nordh on 11/03/2025.
//

import BitcoinUI
import SwiftUI

struct SendManualEntry: View {
    @ObservedObject var viewModel: SendViewModel
    @State var showAmountEntryView = false

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading) {
                Text("Amount")
                    .font(.subheadline.weight(.medium))
                Button {
                    showAmountEntryView.toggle()
                } label: {
                    Text(viewModel.amountSat.formatted(.number.notation(.automatic)))
                        .frame(width: 260, height: 48, alignment: .leading)
                        .tint(viewModel.amountSat == 0 ? .secondary : .primary)
                        .padding([.leading, .trailing], 20)
                        .truncationMode(.middle)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.accentColor, lineWidth: 2)
                        )
                }
                .sheet(
                    isPresented: $showAmountEntryView,
                    content: {
                        AmountEntryView(amount: $viewModel.amountSat)
                    }
                )

            }
            VStack(alignment: .leading) {
                Text("To")
                    .font(.subheadline.weight(.medium))
                ZStack {
                    TextField(
                        "Address or lightning invoice",
                        text: Binding(
                            get: {
                                viewModel.paymentAddress?.address.lowercased().truncateMiddle(
                                    first: 10,
                                    last: 10
                                )
                                    ?? viewModel.address
                            },
                            set: { viewModel.address = $0 }
                        )
                    )
                    .tint(.accentColor)
                    .keyboardType(.numbersAndPunctuation)
                    .disabled(!viewModel.paymentAddress.isNil)
                    .submitLabel(.done)
                    .onChange(of: viewModel.address) {
                        let (extractedAmount, extractedPaymentAddress) =
                            viewModel.address.extractPaymentInfo()

                        if extractedPaymentAddress != nil && viewModel.paymentAddress == nil {
                            viewModel.amountSat = extractedAmount
                            viewModel.paymentAddress = extractedPaymentAddress

                            if extractedAmount != 0 {
                                withAnimation {
                                    viewModel.sendViewState = .reviewPayment
                                }
                            }
                        }
                    }

                    if viewModel.paymentAddress.isNil {
                        HStack {
                            Spacer()
                            Button {
                                withAnimation {
                                    viewModel.sendViewState = .scanAddress
                                }
                            } label: {
                                Label("Scan QR", systemImage: "qrcode.viewfinder")
                                    .labelStyle(.iconOnly)
                                    .foregroundColor(.accentColor)
                            }
                        }
                    } else {
                        HStack {
                            Spacer()
                            Button {
                                withAnimation {
                                    viewModel.paymentAddress = nil
                                    viewModel.address = ""
                                }
                            } label: {
                                Label("Delete", systemImage: "x.circle")
                                    .labelStyle(.iconOnly)
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
                .frame(width: 260, height: 48)
                .padding([.leading, .trailing], 20)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.accentColor, lineWidth: 2)
                ).onChange(of: viewModel.address) { _, newValue in
                    viewModel.address = newValue.replacingOccurrences(of: " ", with: "")
                }
            }
        }.padding(.vertical, 40)

        Spacer()

        Button {
            viewModel.sendViewState = .reviewPayment
        } label: {
            Text("Review")
        }
        .buttonStyle(
            BitcoinFilled(
                tintColor: .accent,
                isCapsule: true
            )
        ).disabled(viewModel.amountSat == 0)
        .padding(.bottom, 40)
    }
}

#Preview {
    SendManualEntry(
        viewModel: SendViewModel.init(
            lightningClient: .mock,
            sendViewState: .manualEntry,
            price: 19000.00,
            balances: .mock
        )
    )
}
