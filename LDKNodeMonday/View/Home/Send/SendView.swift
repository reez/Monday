//
//  SendView.swift
//  LDKNodeMonday
//
//  Created by Daniel Nordh on 10/03/2025.
//

import SwiftUI

import BitcoinUI
import SwiftUI

struct SendView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SendViewModel
    @State var sendViewState: SendViewState
    //@State private var selectedAddressIndex: Int = 0

    var body: some View {

        NavigationView {
            VStack {
                switch sendViewState {
                case .camera:
                    //Text("Camera")
                    AddressView(
                        sendViewState: $sendViewState,
                        spendableBalance: 0
                    )
                case .manual:
                    //Text("SendView")
                    VStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("Amount")
                                .font(.subheadline.weight(.medium))
                            TextField(
                                "0 sats",
                                text: $viewModel.amount
                            )
                            .frame(width: 260, height: 48)
                            .tint(.accentColor)
                            .padding([.leading, .trailing], 20)
                            .keyboardType(.numberPad)
                            .truncationMode(.middle)
                            .submitLabel(.next)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.accentColor, lineWidth: 2)
                            )
                        }
                        VStack(alignment: .leading) {
                            Text("To")
                                .font(.subheadline.weight(.medium))
                            TextField(
                                "Address or lightning invoice",
                                text: $viewModel.address
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
                        //
                    } label: {
                        Text("Review")
                    }
                    .buttonStyle(
                        BitcoinFilled(
                            tintColor: .accent,
                            isCapsule: true
                        )
                    ).disabled(viewModel.amount == "" || viewModel.address == "")
                        .padding(.bottom, 40)
                    
//                    AmountView(
//                        viewModel: .init(lightningClient: viewModel.lightningClient),
//                        address: "",
//                        payment: .none,
//                        //spendableBalance: $viewModel.balances.spendableOnchainBalanceSats,
//                        sendViewState: $sendViewState
//                    )
                case .review:
                    Text("Review")
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
