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
    @State private var isCopied = false
    @State private var showCheckmark = false
    @State private var showingSeedViewErrorAlert = false

    var body: some View {

        VStack(alignment: .center) {
            SeedPhraseView(
                words: viewModel.seed.mnemonic.components(separatedBy: " "),
                preferredWordsPerRow: 2,
                usePaging: true,
                wordsPerPage: 12
            ).padding()

            HStack {
                //Spacer()
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
            .padding(.bottom, 40.0)
        }.dynamicTypeSize(...DynamicTypeSize.accessibility1)  // Sets max dynamic size for all Text
            .navigationTitle("Recovery Phrase")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
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
