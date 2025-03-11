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
    @State var showAmountEntryView = false

    var body: some View {

        NavigationView {
            VStack {
                switch viewModel.sendViewState {
                case .camera:
                    AddressView(
                        viewModel: viewModel,
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
                        viewModel.sendViewState = .review
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
                    SendReviewView(viewModel: viewModel)
                }
            }
            .dynamicTypeSize(...DynamicTypeSize.accessibility2)  // Sets max dynamic size for all Text
            .navigationTitle(viewModel.sendViewState.rawValue)
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
    SendView(viewModel: SendViewModel.init(lightningClient: .mock, sendViewState: .manual))
}
