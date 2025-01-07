//
//  LDKNodeMondayApp.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/20/23.
//

import SwiftUI

@main
struct LDKNodeMondayApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var walletClient: WalletClient = WalletClient(keyClient: KeyClient.live)
    @State private var navigationPath = NavigationPath()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationPath) {
                switch walletClient.appState {
                case .onboarding:
                    OnboardingView(walletClient: $walletClient, viewModel: .init())
                case .wallet:
                    BitcoinView(
                        walletClient: $walletClient,
                        viewModel: .init(priceClient: .live),
                        sendNavigationPath: $navigationPath
                    )
                default:
                    LoadingView()
                }
            }
            .onChange(of: walletClient.appState) { oldValue, newValue in
                navigationPath = NavigationPath()
            }.task {
                await walletClient.start()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func applicationWillTerminate(_ application: UIApplication) {
        try? LightningNodeService.shared.stop()
    }
}
