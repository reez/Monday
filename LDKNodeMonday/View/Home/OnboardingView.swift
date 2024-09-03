//
//  OnboardingView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 1/4/24.
//

import BitcoinUI
import LDKNode
import SwiftUI

struct OnboardingView: View {
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    @AppStorage("isFirstTime") var isFirstTime: Bool = true
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showingOnboardingViewErrorAlert = false

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack {

                Spacer()

                VStack(spacing: 25) {
                    VStack(spacing: -5) {
                        Image(systemName: "bolt.horizontal.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color(hex: "77F3CD"))
                            .frame(width: 100, height: 100)
                        Text("Monday Wallet")
                            .foregroundColor(Color(hex: "77F3CD"))
                            .font(.largeTitle)
                            .fontDesign(.monospaced)
                            .fontWeight(.light)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    Text("LDK Node Lightning Wallet")
                        .foregroundColor(Color(hex: "77F3CD"))
                        .fontDesign(.monospaced)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundColor(Color(uiColor: .label))
                        )
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 50)

                VStack {

                    VStack {
                        Picker(
                            "Network",
                            selection: $viewModel.selectedNetwork
                        ) {
                            Text("Bitcoin").tag(Network.bitcoin)
                            Text("Testnet").tag(Network.testnet)
                            Text("Signet").tag(Network.signet)
                            Text("Regtest").tag(Network.regtest)
                        }
                        .pickerStyle(.automatic)
                        .tint(viewModel.buttonColor)

                        Picker(
                            "Esplora Server",
                            selection: $viewModel.selectedURL
                        ) {
                            ForEach(viewModel.availableURLs, id: \.self) { url in
                                Text(
                                    url.replacingOccurrences(
                                        of: "https://",
                                        with: ""
                                    ).replacingOccurrences(
                                        of: "http://",
                                        with: ""
                                    )
                                )
                                .tag(url)
                            }
                        }
                        .pickerStyle(.automatic)
                        .tint(viewModel.buttonColor)

                    }

                }
                .padding()

                VStack {
                    TextField(
                        isFirstTime
                            ? "24 word Seed Phrase (Optional)" : "24 word Seed Phrase (Required)",
                        text: $viewModel.seedPhrase
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .submitLabel(.done)
                    .padding(.horizontal, 40)
                    if viewModel.seedPhraseArray != [] {
                        SeedPhraseView(
                            words: viewModel.seedPhraseArray,
                            preferredWordsPerRow: 2,
                            usePaging: true,
                            wordsPerPage: 6
                        )
                    }
                }
                .padding()

                Spacer()

                Button {
                    viewModel.saveSeed()
                    isFirstTime = false
                } label: {
                    Text("Start Node")
                        .bold()
                        .foregroundColor(Color(uiColor: UIColor.systemBackground))
                        .frame(maxWidth: .infinity)
                        .minimumScaleFactor(0.9)
                        .padding(.all, 8)
                }
                .frame(width: 200, height: 25)
                .buttonStyle(BitcoinFilled(tintColor: viewModel.buttonColor, isCapsule: true))
                .disabled(!isFirstTime && viewModel.seedPhrase.isEmpty)
                .padding(.all, 25)

            }

        }
        .alert(isPresented: $showingOnboardingViewErrorAlert) {
            Alert(
                title: Text(viewModel.onboardingViewError?.title ?? "Unknown"),
                message: Text(viewModel.onboardingViewError?.detail ?? ""),
                dismissButton: .default(Text("OK")) {
                    viewModel.onboardingViewError = nil
                }
            )
        }

    }
}

#if DEBUG
#Preview {
    OnboardingView(viewModel: .init())
}
#endif
