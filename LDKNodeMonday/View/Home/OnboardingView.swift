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
    
    @State var viewModel: OnboardingViewModel
    
    @State private var showingNetworkSettingsSheet = false
    @State private var showingImportWalletSheet = false
    @State private var showingOnboardingViewErrorAlert = false

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack {
                
                // Network settings
                HStack {
                    Spacer()
                    Button(action: {
                        showingNetworkSettingsSheet.toggle()
                    }, label: {
                        HStack(spacing: 5) {
                            Text(viewModel.selectedNetwork.description.capitalized)
                            Image(systemName: "gearshape")
                        }
                    })
                    .sheet(isPresented: $showingNetworkSettingsSheet) {
                        NetworkSettingsView(viewModel: viewModel)
                    }
                }.padding()
                
                // Logo, name and description
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
                
                // Buttons for creating and importing wallet

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

                Button("Import wallet") {
                    showingImportWalletSheet.toggle()
                }
                .buttonStyle(BitcoinPlain(tintColor: .accent))
                .sheet(isPresented: $showingImportWalletSheet) {
                    ImportWalletView(viewModel: viewModel)
                }

            }.dynamicTypeSize(...DynamicTypeSize.accessibility1) // Sets max dynamic size for all Text

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

    }
}

#if DEBUG
    #Preview {
        OnboardingView(viewModel: .init())
    }
#endif
