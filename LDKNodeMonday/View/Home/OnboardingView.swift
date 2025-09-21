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
        NavigationView {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()

                VStack {
                    // Logo, name and description
                    VStack {
                        Image(systemName: "bolt.horizontal.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.accent)
                            .frame(width: 150, height: 150, alignment: .center)
                            .padding(40)
                        //                            .scaleEffect(animateContent ? 1 : 0)
                        //                            .opacity(animateContent ? 1 : 0)
                        //                            .animation(
                        //                                .spring(response: 0.6, dampingFraction: 0.5),
                        //                                value: animateContent
                        //                            )
                        Group {
                            Text("Monday Wallet")
                                .font(.largeTitle.weight(.semibold))
                            Text("An example bitcoin wallet\npowered by LDK Node")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        //                        .opacity(animateContent ? 1 : 0)
                        //                        .offset(y: animateContent ? 0 : 20)
                        //                        .animation(.easeOut(duration: 0.5).delay(0.3), value: animateContent)
                    }

                    Spacer()

                    // Buttons for creating and importing wallet

                    Group {

                        Button {
                            Task {
                                await viewModel.saveSeed()
                            }
                        } label: {
                            Text("Create wallet")
                                .padding(.all, 10)
                                .padding(.horizontal, 20)
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            showingImportWalletSheet.toggle()
                        } label: {
                            Text("Import wallet")
                                .padding(.all, 10)
                                .padding(.horizontal, 20)
                        }
                        .buttonStyle(.bordered)
                        .sheet(isPresented: $showingImportWalletSheet) {
                            ImportWalletView().environmentObject(viewModel)
                        }

                    }
                    //                    .opacity(animateContent ? 1 : 0)
                    //                    .offset(y: animateContent ? 0 : 30)
                    //                    .animation(.easeOut(duration: 0.5).delay(0.6), value: animateContent)

                }
                .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
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
                                    Image(systemName: "gearshape")
                                }
                                .fontWeight(.medium)
                            }
                        )
                        //                        .opacity(animateContent ? 1 : 0)
                        //                        .offset(x: animateContent ? 0 : 100)
                        //                        .animation(.easeOut(duration: 0.5).delay(0.6), value: animateContent)
                    }
                }
                .sheet(isPresented: $showingNetworkSettingsSheet) {
                    NavigationView {
                        NetworkSettingsView(walletClient: viewModel.$walletClient)
                    }
                }

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
            //                .onAppear {
            //                    withAnimation {
            //                        animateContent = true
            //                    }
            //                }
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
