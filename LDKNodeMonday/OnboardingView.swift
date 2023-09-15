//
//  OnboardingView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 9/14/23.
//

import BitcoinUI
import SwiftUI

// Can't make @Observable yet
// https://developer.apple.com/forums/thread/731187
// Feature or Bug?
class OnboardingViewModel: ObservableObject {
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    //let ldkClient: LightningNodeService//let bdkClient: BDKClient

//    init(bdkClient: BDKClient = .live) {
//        self.bdkClient = bdkClient
//    }

//    init(ldkClient: LightningNodeService) {
//        self.ldkClient = ldkClient
//    }

    func createWallet() {
        do {
           try LightningNodeService.shared.createWallet() //try bdkClient.createWallet()
            isOnboarding = false
        } catch let error as WalletError {
            print("createWallet - Wallet Error: \(error.localizedDescription)")
        } catch {
            print("createWallet - Undefined Error: \(error.localizedDescription)")
        }
    }
    
    func restoreWallet() {
        do {
            try LightningNodeService.shared.loadWallet() //try bdkClient.loadWallet()
            isOnboarding = false
        } catch let error as WalletError {
            print("restoreWallet - Wallet Error: \(error.localizedDescription)")
        } catch {
            print("restoreWallet - Undefined Error: \(error.localizedDescription)")
        }
    }

}


struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @AppStorage("isOnboarding") var isOnboarding: Bool?

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack {

                Spacer()

                VStack(spacing: 25) {

                    Image(systemName: "bitcoinsign.circle.fill")
                        .resizable()
                        .foregroundColor(.bitcoinOrange)
                        .frame(width: 100, height: 100, alignment: .center)

                    Text("Bitcoin Wallet")
                        .textStyle(BitcoinTitle1())
                        .multilineTextAlignment(.center)
                        .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))

                    Text("A simple bitcoin wallet for your enjoyment.")
                        .textStyle(BitcoinBody1())
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                }

                VStack(spacing: 25) {

                    Button("Create a new wallet") {
                        viewModel.createWallet()
                    }
                    .buttonStyle(BitcoinFilled(tintColor: .bitcoinOrange, isCapsule: true))

                }
                .padding(.top, 30)

                Spacer()

                VStack {
                    Text("Your wallet, your coins")
                        .textStyle(BitcoinBody4())
                        .multilineTextAlignment(.center)
                    Text("100% open-source & open-design")
                        .textStyle(BitcoinBody4())
                        .multilineTextAlignment(.center)
                }
                .padding(EdgeInsets(top: 32, leading: 32, bottom: 8, trailing: 32))

            }
            .task {
                viewModel.restoreWallet()
            }
        }

    }
}


#Preview {
    // TODO: I don't know how much this makes sense atm
    OnboardingView(viewModel: .init())
}
