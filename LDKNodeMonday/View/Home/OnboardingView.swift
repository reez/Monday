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

    @State private var showingOnboardingViewErrorAlert = false
    @State private var showingNetworkSettingsSheet = false
    @State private var showingImportWalletSheet = false
    @State private var animateContent = false

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack {

                // Network settings
                HStack {
                    Spacer()
                    Button(
                        action: {
                            showingNetworkSettingsSheet.toggle()
                        },
                        label: {
                            HStack(spacing: 5) {
                                Text(
                                    viewModel.walletClient.network.description
                                        .capitalized
                                )
                                .opacity(animateContent ? 1 : 0)
                                .offset(x: animateContent ? 0 : 100)
                                Image(systemName: "gearshape")
                                    .opacity(animateContent ? 1 : 0)
                                    .offset(x: animateContent ? 0 : 100)
                            }
                        }
                    )
                    .sheet(isPresented: $showingNetworkSettingsSheet) {
                        NavigationView {
                            NetworkSettingsView(walletClient: viewModel.$walletClient)
                        }
                    }
                }
                .fontWeight(.medium)
                .padding()
                .animation(.easeOut(duration: 0.5).delay(0.6), value: animateContent)

                // Logo, name and description
                VStack {
                    Image(systemName: "bolt.horizontal.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.accent)
                        .frame(width: 150, height: 150, alignment: .center)
                        .padding(40)
                        .scaleEffect(animateContent ? 1 : 0)
                        .opacity(animateContent ? 1 : 0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.5),
                            value: animateContent
                        )
                    Group {
                        Text("Monday Wallet")
                            .font(.largeTitle.weight(.semibold))
                        Text("An example bitcoin wallet\npowered by LDK Node")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: animateContent)
                }

                Spacer()

                // Buttons for creating and importing wallet

                Group {
                    Button("Create wallet") {
                        Task {
                            await viewModel.saveSeed()
                        }
                    }
                    .buttonStyle(
                        BitcoinFilled(
                            tintColor: .accent,
                            isCapsule: true
                        )
                    )

                    Button("Import wallet") {
                        showingImportWalletSheet.toggle()
                    }
                    .buttonStyle(BitcoinPlain(tintColor: .accent))
                    .sheet(isPresented: $showingImportWalletSheet) {
                        ImportWalletView().environmentObject(viewModel)
                    }
                }
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 30)
                .animation(.easeOut(duration: 0.5).delay(0.6), value: animateContent)

            }.dynamicTypeSize(...DynamicTypeSize.accessibility2)  // Sets max dynamic size for all Text

        }.padding(.bottom, 20)
            .alert(isPresented: $showingOnboardingViewErrorAlert) {
                Alert(
                    title: Text(viewModel.onboardingViewError?.title ?? "Unknown error"),
                    message: Text(viewModel.onboardingViewError?.detail ?? "No details"),
                    dismissButton: .default(Text("OK")) {
                        viewModel.onboardingViewError = nil
                    }
                )
            }
            .onAppear {
                withAnimation {
                    animateContent = true
                }
            }

    }
}

#if DEBUG
    #Preview {
        OnboardingView(
            viewModel: .init(
                walletClient: .constant(WalletClient(appMode: AppMode.mock))
            )
        )
    }
#endif
