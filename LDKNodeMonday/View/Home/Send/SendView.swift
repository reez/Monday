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
                        viewModel: viewModel,
                        spendableBalance: 0
                    )
                case .manualEntry:
                    SendManualEntry(viewModel: viewModel)
                case .reviewPayment:
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
    SendView(viewModel: SendViewModel.init(lightningClient: .mock, sendViewState: .manualEntry))
}
