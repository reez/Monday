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

            Picker("Options", selection: $selectedOption) {
                ForEach(ReceiveOption.allCases, id: \.self) { option in
                    HStack(spacing: 5) {
                        Image(systemName: option.systemImageName)
                        Text(option.rawValue)
                    }
                    .tag(option)
                }
            }
            .pickerStyle(.menu)

            Spacer()

            switch selectedOption {
            case .bolt11JIT:
                JITInvoiceView(viewModel: .init())
            case .bip21:
                BIP21View(viewModel: .init())
            }

        }
        .padding()
        .padding(.vertical, 40.0)

    }

}

#Preview {
    ReceiveView()
}
