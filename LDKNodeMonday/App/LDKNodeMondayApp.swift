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
    @State private var walletState: WalletState = WalletState(keyClient: KeyClient.live)
    @State private var navigationPath = NavigationPath()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationPath) {
                switch walletState.appNavigation {
                case .onboarding:
                    OnboardingView(viewModel: .init())
                case .wallet:
                    BitcoinView(
                        viewModel: .init(priceClient: .live),
                        sendNavigationPath: $navigationPath
                    )
                default:
                    LoadingView()
                }
            }
            .onChange(of: walletState.appNavigation) { oldValue, newValue in
                navigationPath = NavigationPath()
            }.task {
                await walletState.start()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func applicationWillTerminate(_ application: UIApplication) {
        try? LightningNodeService.shared.stop()
    }
}
