//
//  SendReviewView.swift
//  LDKNodeMonday
//
//  Created by Daniel Nordh on 11/03/2025.
//

import BitcoinUI
import SwiftUI

struct SendReviewView: View {
    @ObservedObject var viewModel: SendViewModel

    var body: some View {
        VStack {
            List {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Amount")
                        .font(.subheadline.weight(.medium))
                    HStack {
                        Text(viewModel.amountSat.formatted(.number.notation(.automatic)))
                        Spacer()
                        Text(viewModel.amountSat.formattedSatsAsUSD(price: viewModel.price))
                    }
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text("To")
                        .font(.subheadline.weight(.medium))
                    Text(viewModel.paymentAddress?.address.lowercased() ?? "No address")
                        .truncationMode(.middle)
                        .lineLimit(1)
                }

            }
            .listStyle(.plain)
            .padding(20)

            Spacer()
            if disableSend() {
                Label("Insufficient Funds", systemImage: "x.circle")
                    .padding(40)
            }

            Button.init {
                Task {
                    try await viewModel.send()
                }
                if viewModel.sendError == nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        withAnimation {
                            viewModel.sendViewState = .paymentSent
                        }
                    }
                }
            } label: {
                Text("Send")
                    .padding(.all, 10)
                    .padding(.horizontal, 80)
            }
            .padding(.bottom, 40)
            .buttonStyle(.borderedProminent)
            .disabled(disableSend())

        }
    }

    func disableSend() -> Bool {
        if viewModel.paymentAddress.isNil {
            return true
        } else {
            switch viewModel.paymentAddress!.type {
            case .onchain:
                return viewModel.amountSat > viewModel.balances.spendableOnchainBalanceSats
            case .bip21:
                return viewModel.amountSat > viewModel.balances.spendableOnchainBalanceSats
                    && viewModel.amountSat > viewModel.balances.totalLightningBalanceSats
            case .bolt11, .bolt11Jit, .bolt12:
                return viewModel.amountSat > viewModel.balances.totalLightningBalanceSats
            }
        }
    }
}

#Preview {
    SendReviewView(
        viewModel: SendViewModel.init(
            lightningClient: .mock,
            sendViewState: .manualEntry,
            price: 19000.00,
            balances: .mock
        )
    )
}
