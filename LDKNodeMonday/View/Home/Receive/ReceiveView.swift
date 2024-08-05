//
//  ReceiveView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/25/24.
//

import SwiftUI

struct ReceiveView: View {
    @State private var selectedOption: ReceiveOption = .bip21

    var body: some View {

        VStack {

            CustomSegmentedPicker(options: ReceiveOption.allCases, selectedOption: $selectedOption)

            Spacer()

            switch selectedOption {
//            case .bolt11Zero:
//                ZeroInvoiceView(viewModel: .init())
//            case .bolt11:
//                AmountInvoiceView(viewModel: .init())
            case .bolt11JIT:
                JITInvoiceView(viewModel: .init())
            //            case .bolt12Zero:
            //                Bolt12ZeroInvoiceView(viewModel: .init())
//            case .bolt12:
//                Bolt12InvoiceView(viewModel: .init())
//            case .bitcoin:
//                AddressView(viewModel: .init())
            case .bip21:
                BIP21View(viewModel: .init())
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
                    VStack {
                        Image(systemName: option.systemImageName)
                            //.font(.system(size: 6))
                        Text(option.rawValue)
                            //.font(.system(size: 6))
                    }
                    .padding()
                    .font(.body)
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
    CustomSegmentedPicker(options: ReceiveOption.allCases, selectedOption: .constant(.bip21))
}
