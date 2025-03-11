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

        Button {
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
        }
        .buttonStyle(
            BitcoinFilled(
                tintColor: .accent,
                isCapsule: true
            )
        )
        .disabled(viewModel.paymentAddress.isNil)
        .padding(.bottom, 40)
    }
}

#Preview {
    SendReviewView(
        viewModel: SendViewModel.init(
            lightningClient: .mock,
            sendViewState: .manualEntry,
            price: 19000.00
        )
    )
}
