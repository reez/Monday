//
//  AmountEntryView.swift
//  LDKNodeMonday
//
//  Created by Daniel Nordh on 25/02/2025.
//

import BitcoinUI
import SwiftUI

struct AmountEntryView: View {
    @Binding var amount: UInt64
    @Environment(\.dismiss) private var dismiss

    @State private var numpadAmount = "0"

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                VStack {
                    Text(numpadAmount.formattedAmount(defaultValue: "0"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                    HStack(spacing: 5) {
                        Text("sats")
                            .contentTransition(.interpolate)
                    }
                    .foregroundColor(.secondary)
                    .font(.system(.headline, design: .rounded, weight: .medium))
                }
                .animation(.spring(), value: amount)
                .sensoryFeedback(.increase, trigger: numpadAmount)

                Spacer()

                GeometryReader { geometry in
                    let buttonSize = geometry.size.width / 4
                    VStack(spacing: buttonSize / 12) {
                        numpadRow(["1", "2", "3"], buttonSize: buttonSize)
                        numpadRow(["4", "5", "6"], buttonSize: buttonSize)
                        numpadRow(["7", "8", "9"], buttonSize: buttonSize)
                        numpadRow([" ", "0", "<"], buttonSize: buttonSize)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 300)
                .padding(.horizontal, 50)
                .padding(.bottom, 30)

//                Button {
//                    amount = UInt64(numpadAmount) ?? 0
//                    dismiss()
//                } label: {
//                    Text("Done")
//                }
//                .buttonStyle(
//                    BitcoinOutlined(
//                        tintColor: .accent,
//                        isCapsule: true
//                    )
//                )
                
                Button.init {
                    amount = UInt64(numpadAmount) ?? 0
                    dismiss()
                } label: {
                    Text("Done")
                        .padding(.all, 10)
                        .padding(.horizontal, 80)
                }
                .buttonStyle(.borderedProminent)
                
                

            }
            .padding(.bottom, 20)
            .dynamicTypeSize(...DynamicTypeSize.accessibility2)  // Sets max dynamic size for all Text
            .navigationTitle("Amount")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func numpadRow(_ characters: [String], buttonSize: CGFloat) -> some View {
        HStack(spacing: buttonSize / 2) {
            ForEach(characters, id: \.self) { character in
                NumpadButton(numpadAmount: $numpadAmount, character: character)
                    .frame(width: buttonSize, height: buttonSize)
            }
        }
    }
}

struct NumpadButton: View {
    @Binding var numpadAmount: String
    var character: String

    var body: some View {
        Button {
            if character == "<" {
                if numpadAmount.count > 1 {
                    numpadAmount.removeLast()
                } else {
                    numpadAmount = "0"
                }
            } else if character == " " {
                return
            } else {
                if numpadAmount == "0" {
                    numpadAmount = character
                } else {
                    numpadAmount.append(character)
                }
            }
        } label: {
            if character == "<" {
                Image(systemName: "delete.left")
                    .bold()
                    .foregroundColor(.primary)
            } else {
                Text(character)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
        }
    }
}
