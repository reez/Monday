//
//  ReceiveView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/25/24.
//

import SwiftUI

struct ReceiveView: View {
    @State private var selectedOption: ReceiveOption = .zeroInvoice

    var body: some View {

        VStack {

            CustomSegmentedPicker(options: ReceiveOption.allCases, selectedOption: $selectedOption)

            Spacer()

            switch selectedOption {
            case .bitcoin:
                AddressView(viewModel: .init())
            case .zeroInvoice:
                ZeroInvoiceView(viewModel: .init())
            case .amountInvoice:
                AmountInvoiceView(viewModel: .init())
            case .jitInvoice:
                JITInvoiceView(viewModel: .init())
            }

        }
        .padding()
        .padding(.vertical, 40.0)

    }
}

struct CustomSegmentedPicker: View {
    let options: [ReceiveOption]
    @Binding var selectedOption: ReceiveOption

    var body: some View {
        HStack {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    self.selectedOption = option
                }) {
                    HStack {
                        Image(systemName: option.systemImageName)
                        Text(option.rawValue)
                    }
                    .padding()
                    .font(.caption2)
                    .foregroundColor(
                        self.selectedOption == option ? Color.primary : Color.secondary
                    )

                }
            }
        }

    }
}

#Preview {
    ReceiveView()
}

#Preview {
    CustomSegmentedPicker(options: ReceiveOption.allCases, selectedOption: .constant(.zeroInvoice))
}
