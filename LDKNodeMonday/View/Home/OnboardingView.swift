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
    
    let airdropOptions = ["Receiving Off", "Contacts Only", "Everyone for 10 minutes"]
    @State private var selectedAirdropOption = "Receiving Off"

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack {

                Spacer()

                VStack {
                    Image(systemName: "bolt.horizontal.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.accent)
                        .frame(width: 150, height: 150, alignment: .center)
                        .padding(40)
                    Text("Monday Wallet")
                        .font(.largeTitle .weight(.semibold))
                    Text("An example bitcoin wallet\npowered by LDK Node")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                NavigationStack {
                    // Default picker style
                    /*
                    HStack {
                        Text("Network")
                        Spacer()
                        Picker(
                            "Network",
                            selection: $viewModel.selectedNetwork
                        ) {
                            Text("Signet").tag(Network.signet)
                            Text("Testnet").tag(Network.testnet)
                        }
                        .pickerStyle(.automatic)
                        .tint(.accent)
                        .accessibilityLabel("Select bitcoin network")
                    }
                    HStack {
                        Text("Server")
                        Spacer()
                        Picker(
                            "Esplora server",
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
                        .tint(.accent)
                        .accessibilityLabel("Select esplora server")
                    }
                     */
                    // NavigationLink picker style
                    Form {
                        Section() {
                            Picker(
                                "Network",
                                selection: $viewModel.selectedNetwork
                            ) {
                                Text("Signet").tag(Network.signet)
                                Text("Testnet").tag(Network.testnet)
                            }
                            .pickerStyle(.navigationLink)
                            .accessibilityLabel("Select bitcoin network")
                            .scrollContentBackground(.hidden)
                            Picker(
                                "Esplora server",
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
                            .pickerStyle(.navigationLink)
                            .accessibilityLabel("Select esplora server")
                            .scrollContentBackground(.hidden)
                        }
                    }
                    .tint(.accent)
                    .frame(maxHeight: 150)
                    .scrollContentBackground(.hidden)
                }
                .padding(.horizontal, 20)

                // Textfield for importing wallet
                TextField(
                    isFirstTime
                        ? "24 word seed phrase (optional)" : "24 word seed phrase (required)",
                    text: $viewModel.seedPhrase
                )
                .textFieldStyle(.roundedBorder)
                .submitLabel(.done)
                .padding(.horizontal, 50)
                .padding(.vertical, 10)
                if viewModel.seedPhraseArray != [] {
                    SeedPhraseView(
                        words: viewModel.seedPhraseArray,
                        preferredWordsPerRow: 2,
                        usePaging: true,
                        wordsPerPage: 6
                    )
                }

                Spacer()

                Button("Create wallet") {
                    viewModel.saveSeed()
                    isFirstTime = false
                }
                .buttonStyle(
                    BitcoinFilled(
                        tintColor: .accent,
                        isCapsule: true
                    )
                )
                .padding()

            }.dynamicTypeSize(...DynamicTypeSize.accessibility1) // Sets max dynamic size for all Text

        }.padding(.bottom, 20)
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
