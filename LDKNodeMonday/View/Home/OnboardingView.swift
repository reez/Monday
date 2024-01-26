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
    @ObservedObject var viewModel: OnboardingViewModel
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    @State private var showingOnboardingViewErrorAlert = false
    @AppStorage("isFirstTime") var isFirstTime: Bool = true

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
                    }
                    Text("LDK Node Lightning Wallet")
                        .foregroundColor(Color(hex: "77F3CD"))
                        .fontDesign(.monospaced)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundColor(Color(uiColor: .label))
                        )
                }
                .padding(.all, 50)

                VStack {

                    Text("Choose your Network. This is final.")
                        .textStyle(BitcoinBody4())
                        .multilineTextAlignment(.center)

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
                    .padding(.horizontal, 40)
                }
                .padding()

                VStack(spacing: 25) {
                    Button("Start Node") {
                        viewModel.saveSeed()
                        isFirstTime = false
                    }
                    .buttonStyle(BitcoinFilled(tintColor: viewModel.buttonColor, isCapsule: true))
                    .disabled(!isFirstTime && viewModel.seedPhrase.isEmpty)
                }
                .padding(.all, 25)

                Spacer()

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

#Preview {
    OnboardingView(viewModel: .init())
}
