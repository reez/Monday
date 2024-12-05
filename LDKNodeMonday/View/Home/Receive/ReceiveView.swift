//
//  ReceiveView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/25/24.
//

import BitcoinUI
import SwiftUI

struct ReceiveView: View {
    @State private var selectedOption: ReceiveOption = .bolt11JIT  //.bip21 // TODO: go back to bip21

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
            .tint(.primary)

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

struct AmountEntryView: View {
    @Binding var amount: String
    @Environment(\.dismiss) private var dismiss

    @State private var numpadAmount = "0"

    var body: some View {
        VStack(spacing: 20) {

            Spacer()

            Text("\(numpadAmount.formattedAmount(defaultValue: "0")) sats")
                .textStyle(BitcoinTitle1())
                .padding()

            GeometryReader { geometry in
                let buttonSize = geometry.size.width / 4
                VStack(spacing: buttonSize / 10) {
                    numpadRow(["1", "2", "3"], buttonSize: buttonSize)
                    numpadRow(["4", "5", "6"], buttonSize: buttonSize)
                    numpadRow(["7", "8", "9"], buttonSize: buttonSize)
                    numpadRow([" ", "0", "<"], buttonSize: buttonSize)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: 300)

            Spacer()

            Button {
                amount = numpadAmount
                dismiss()
            } label: {
                HStack(spacing: 1) {
                    Text("Confirm")
                        .padding(.horizontal, 40)
                        .padding(.vertical, 5)
                }
                .foregroundColor(Color(uiColor: UIColor.systemBackground))
                .bold()
            }
            .buttonBorderShape(.capsule)
            .buttonStyle(.borderedProminent)
            .tint(.primary)

        }
        .padding()
    }

    func numpadRow(_ characters: [String], buttonSize: CGFloat) -> some View {
        HStack(spacing: buttonSize / 2) {
            ForEach(characters, id: \.self) { character in
                NumpadButton(numpadAmount: $numpadAmount, character: character)
                    .frame(width: buttonSize, height: buttonSize / 1.5)
            }
        }
    }
}

struct InvoiceRowView: View {
    let title: String
    let value: String
    let isCopied: Bool
    let showCheckmark: Bool
    let networkColor: Color
    let onCopy: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 5.0) {
                Text(title)
                    .bold()
                Text(value)
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
                    .redacted(reason: value.isEmpty ? .placeholder : [])
            }
            .font(.caption2)

            Spacer()

            Button(action: onCopy) {
                HStack {
                    withAnimation {
                        Image(systemName: showCheckmark ? "checkmark" : "doc.on.doc")
                            .font(.title3)
                            .minimumScaleFactor(0.5)
                    }
                }
                .bold()
                .foregroundColor(networkColor)
            }
            .font(.caption2)
        }
        .padding(.horizontal)
    }
}

#if DEBUG
    #Preview {
        AmountEntryView(
            amount: .constant("21")
        )
    }
#endif
