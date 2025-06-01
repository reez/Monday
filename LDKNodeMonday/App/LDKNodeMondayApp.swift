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

    @State private var walletClient: WalletClient? = nil
    @State private var navigationPath = NavigationPath()

    init() {}

    var body: some Scene {
        WindowGroup {
            Group {
                if let walletClient = walletClient {
                    NavigationStack(path: $navigationPath) {
                        switch walletClient.appState {
                        case .onboarding:
                            OnboardingView(
                                viewModel: .init(
                                    walletClient: Binding(
                                        get: { self.walletClient! },
                                        set: { self.walletClient = $0 }
                                    )
                                )
                            )
                        case .wallet:
                            BitcoinView(
                                viewModel: .init(
                                    walletClient: Binding(
                                        get: { self.walletClient! },
                                        set: { self.walletClient = $0 }
                                    ),
                                    priceClient: .live,
                                    lightningClient: walletClient.lightningClient
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
                } else {
                    LoadingView()
                }
            }
            .task {
                if walletClient == nil {
                    do {
                        let client = try await WalletClient.create(appMode: .live)
                        walletClient = client
                        AppDelegate.shared.walletClient = client
                    } catch {
                        let errorClient = WalletClient.mock
                        errorClient.appState = .error
                        errorClient.appError = error
                        walletClient = errorClient
                    }
                }
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
