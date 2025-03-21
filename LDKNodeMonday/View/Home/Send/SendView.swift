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

    var body: some View {

        NavigationView {
            VStack {
                switch viewModel.sendViewState {
                case .scanAddress:
                    SendScanAddressView(
                        viewModel: viewModel
                    )
                case .manualEntry:
                    SendManualEntry(viewModel: viewModel)
                case .reviewPayment:
                    SendReviewView(viewModel: viewModel)
                case .paymentSent:
                    VStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.accent)
                            .frame(width: 150, height: 150, alignment: .center)
                            .padding(40)
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Text("Done")
                        }
                        .buttonStyle(
                            BitcoinFilled(
                                tintColor: .accent,
                                isCapsule: true
                            )
                        )
                        .padding(.bottom, 40)
                    }
                }
            }
            .dynamicTypeSize(...DynamicTypeSize.accessibility2)  // Sets max dynamic size for all Text
            .navigationTitle(viewModel.sendViewState.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.sendViewState != .paymentSent {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    //await viewModel.generateAddresses()
                }
            }
        }
        .alert(
            isPresented: Binding<Bool>(
                get: { viewModel.sendError != nil },
                set: { if !$0 { viewModel.sendError = nil } }
            )
        ) {
            Alert(
                title: Text(viewModel.sendError?.title ?? "Unknown"),
                message: Text(viewModel.sendError?.detail ?? ""),
                dismissButton: .default(Text("OK")) {
                    viewModel.sendError = nil
                }
            )
        }

    }
}

#Preview {
    SendView(
        viewModel: SendViewModel.init(
            lightningClient: .mock,
            sendViewState: .paymentSent,
            price: 19000.00,
            balances: .mock
        )
    )
}
