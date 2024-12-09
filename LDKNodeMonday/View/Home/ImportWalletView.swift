//
//  ImportWalletView.swift
//  LDKNodeMonday
//
//  Created by Daniel Nordh on 28/11/2024.
//

import BitcoinUI
import LDKNode
import SwiftUI

struct ImportWalletView: View {
    @Environment(\.dismiss) private var dismiss

    @Bindable var viewModel: OnboardingViewModel

    @State private var seedPhrase = ""

    var body: some View {
        NavigationView {
            VStack {

                Spacer()

                // Textfield for importing wallet

                if viewModel.seedPhraseArray == [] {
                    VStack(spacing: 10) {
                        Text("Enter or paste your recovery phrase")
                        TextField(
                            "24 word recovery phrase",
                            text: $viewModel.seedPhrase
                        )
                        .frame(width: 260, height: 48)
                        .tint(.accentColor)
                        .padding([.leading, .trailing], 20)
                        .submitLabel(.done)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.accentColor, lineWidth: 2)
                        )
                    }
                } else {
                    SeedPhraseView(
                        words: viewModel.seedPhraseArray,
                        preferredWordsPerRow: 2,
                        usePaging: true,
                        wordsPerPage: 12
                    )
                }

                Spacer()

                // Button for importing wallet

                Button("Import wallet") {
                    viewModel.saveSeed()
                }
                .buttonStyle(
                    BitcoinFilled(
                        tintColor: .accent,
                        isCapsule: true
                    )
                )
                .disabled(viewModel.seedPhraseArray == [] ? true : false)
                .padding()

            }
            .navigationTitle("Import wallet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(
                        action: {
                            dismiss()
                        },
                        label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left").fontWeight(.medium)
                                Text("Back")
                            }
                        }
                    )
                }
            }
        }
        .padding(.bottom, 20)
        .accentColor(.accentColor)
    }
}

#if DEBUG
    #Preview {
        ImportWalletView(viewModel: .init())
    }
#endif
