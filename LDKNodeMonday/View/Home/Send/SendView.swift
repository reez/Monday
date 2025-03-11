//
//  SendView.swift
//  LDKNodeMonday
//
//  Created by Daniel Nordh on 10/03/2025.
//

import BitcoinUI
import SwiftUI

struct SendView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SendViewModel
    @State var sendViewState: SendViewState
    @State var showAmountEntryView = false

    var body: some View {

        NavigationView {
            VStack {
                switch sendViewState {
                case .camera:
                    AddressView(
                        amount: $viewModel.amountSat,
                        paymentAddress: $viewModel.paymentAddress,
                        sendViewState: $sendViewState,
                        spendableBalance: 0
                    )
                case .manual:
                    VStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("Amount")
                                .font(.subheadline.weight(.medium))
                            Button {
                                showAmountEntryView.toggle()
                            } label: {
                                Text(viewModel.amountSat.description)
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
                            TextField(
                                "Address or lightning invoice",
                                text: Binding(
                                    get: { viewModel.paymentAddress?.address ?? viewModel.address },
                                    set: { viewModel.address = $0 }
                                )
                            )
                            .frame(width: 260, height: 48)
                            .tint(.accentColor)
                            .padding([.leading, .trailing], 20)
                            .keyboardType(.numbersAndPunctuation)
                            .truncationMode(.middle)
                            .submitLabel(.next)
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
                        sendViewState = .review
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
                case .review:
                    List {
                        VStack {
                            Text("Amount")
                                .font(.subheadline.weight(.medium))
                            Text(viewModel.amountSat.description)
                        }
                        VStack(alignment: .leading) {
                            Text("To")
                                .font(.subheadline.weight(.medium))
                            Text(viewModel.paymentAddress?.address ?? "No address")
                                .truncationMode(.middle)
                                .lineLimit(1)
                        }

                    }
                    .listStyle(.plain)
                    .padding(20)

                    Spacer()

                    Button {
                        //
                    } label: {
                        Text("Send")
                    }
                    .buttonStyle(
                        BitcoinFilled(
                            tintColor: .accent,
                            isCapsule: true
                        )
                    )
                    //.disabled()
                    .padding(.bottom, 40)
                }
            }
            .dynamicTypeSize(...DynamicTypeSize.accessibility2)  // Sets max dynamic size for all Text
            .navigationTitle(sendViewState.rawValue)
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
                    //await viewModel.generateAddresses()
                }
            }
        }

    }
}

#Preview {
    SendView(viewModel: SendViewModel.init(lightningClient: .mock), sendViewState: .manual)
}
