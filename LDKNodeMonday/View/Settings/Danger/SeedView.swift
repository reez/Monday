//
//  SeedView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 12/30/23.
//

import BitcoinUI
import LDKNode
import SwiftUI

struct SeedView: View {
    @ObservedObject var viewModel: SeedViewModel
    @State private var showAlert = false
    @State private var showRecoveryPhrase = false
    @State private var isCopied = false
    @State private var showCheckmark = false
    @State private var showingSeedViewErrorAlert = false

    var body: some View {

        VStack(alignment: .center) {

            if !showRecoveryPhrase {
                Spacer()
                Text(
                    "Warning! \n\n Never share the recovery phrase. Doing so will put your funds at risk."
                )
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(40)
                Spacer()
                Button("Show Recovery Phrase") {
                    showAlert = true
                }.buttonStyle(BitcoinFilled(tintColor: .accentColor, isCapsule: true))
                    .alert(
                        "Are you sure you want to view the recovery phrase?",
                        isPresented: $showAlert
                    ) {
                        Button("Yes", role: .destructive) { showRecoveryPhrase = true }
                        Button("No", role: .cancel) {}
                    }
            } else {
                SeedPhraseView(
                    words: viewModel.seed.mnemonic.components(separatedBy: " "),
                    preferredWordsPerRow: 2,
                    usePaging: true,
                    wordsPerPage: 12
                ).padding()

                HStack {
                    Button(
                        "Copy Recovery Phrase",
                        systemImage: showCheckmark
                            ? "checkmark" : "doc.on.doc"
                    ) {
                        UIPasteboard.general.string = viewModel.seed.mnemonic
                        isCopied = true
                        showCheckmark = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isCopied = false
                            showCheckmark = false
                        }
                    }
                    .buttonStyle(.automatic)
                    .controlSize(.mini)
                    //Spacer()

                }

            }
        }.dynamicTypeSize(...DynamicTypeSize.accessibility1)  // Sets max dynamic size for all Text
            .navigationTitle("Recovery Phrase")
            .navigationBarTitleDisplayMode(.inline)
            .padding(.bottom, 40.0)
            .onAppear {
                viewModel.getSeed()
            }
            .alert(isPresented: $showingSeedViewErrorAlert) {
                Alert(
                    title: Text(viewModel.seedViewError?.title ?? "Unknown"),
                    message: Text(viewModel.seedViewError?.detail ?? ""),
                    dismissButton: .default(Text("OK")) {
                        viewModel.seedViewError = nil
                    }
                )
            }

    }
}

#if DEBUG
    #Preview {
        SeedView(viewModel: .init())
    }
#endif
