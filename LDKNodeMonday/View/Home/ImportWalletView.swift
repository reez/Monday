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
    
    @AppStorage("isFirstTime") var isFirstTime: Bool = true
    @State private var seedPhrase = ""
    //@EnvironmentObject var viewModel: OnboardingViewModel
    
    var body: some View {
        NavigationView {
            VStack () {
                
                Spacer()
                
                // Textfield for importing wallet
                TextField("24 word seed phrase (required)",
                          text: $seedPhrase //$viewModel.seedPhrase
                )
                .textFieldStyle(.roundedBorder)
                .submitLabel(.done)
                .padding(.horizontal, 50)
                .padding(.vertical, 10)
//                if viewModel.seedPhraseArray != [] {
//                    SeedPhraseView(
//                        words: viewModel.seedPhraseArray,
//                        preferredWordsPerRow: 2,
//                        usePaging: true,
//                        wordsPerPage: 6
//                    )
//                }
                
                Spacer()
                
                // Buttons for creating and importing wallet

                Button("Import wallet") {
                    //
                }
                .buttonStyle(
                    BitcoinFilled(
                        tintColor: .accent,
                        isCapsule: true
                    )
                )
                .disabled(seedPhrase == "" ? true : false)
                .padding()

            }
            .navigationTitle("Import wallet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    })
                }
            }
        }
        .padding(.bottom, 20)
        .accentColor(.accentColor)
    }
}

#Preview {
    ImportWalletView()
    //ImportWalletView(viewModel: .init())
}
