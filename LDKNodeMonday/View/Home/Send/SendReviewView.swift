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

#Preview {
    SendReviewView(viewModel: SendViewModel.init(lightningClient: .mock, sendViewState: .manualEntry))
}
