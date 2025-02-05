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

    @State private var walletClient = WalletClient(mode: .live)
    @State private var navigationPath = NavigationPath()

    init() {
        AppDelegate.shared.walletClient = walletClient
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationPath) {
                switch walletClient.appState {
                case .onboarding:
                    OnboardingView(
                        viewModel: .init(
                            walletClient: $walletClient
                        )
                    )
                case .wallet:
                    BitcoinView(
                        viewModel: .init(
                            walletClient: $walletClient,
                            priceClient: .live
                        ),
                        sendNavigationPath: $navigationPath
                    )
                case .error:
                    ErrorView(error: walletClient.appError)
                default:
                    LoadingView()
                }
            }
            .onChange(of: walletClient.appState) { oldValue, newValue in
                navigationPath = NavigationPath()
            }
            .task {
                await walletClient.start()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    static let shared = AppDelegate()
    var walletClient: WalletClient?

    func applicationWillTerminate(_ application: UIApplication) {
        walletClient?.stop()
    }
}
