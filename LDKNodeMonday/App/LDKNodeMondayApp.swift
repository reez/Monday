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

    private let lightningClient: LightningNodeClient = .live
    @State private var appState = AppState.loading
    @State private var appError: Error?
    @State private var navigationPath = NavigationPath()

    init() {
        AppDelegate.shared.lightningClient = lightningClient
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationPath) {
                switch appState {
                case .onboarding:
                    OnboardingView(
                        viewModel: .init(appState: $appState, lightningClient: lightningClient)
                    )
                case .wallet:
                    BitcoinView(
                        viewModel: .init(
                            appState: $appState,
                            priceClient: .live,
                            lightningClient: lightningClient
                        ),
                        sendNavigationPath: $navigationPath
                    )
                case .error:
                    ErrorView(error: self.appError)
                default:
                    LoadingView()
                }
            }
            .onChange(of: appState) { oldValue, newValue in
                navigationPath = NavigationPath()
            }
            .task {
                await start()
            }
        }
    }

    func start() async {
        var backupInfo: BackupInfo?

        backupInfo = try? KeyClient.live.getBackupInfo()

        if backupInfo != nil {
            do {
                // TODO: .start could take parameters from backupInfo (seed, network, url, lsp)
                try await lightningClient.start()
                lightningClient.listenForEvents()
                await MainActor.run {
                    self.appState = .wallet
                }
            } catch let error {
                await MainActor.run {
                    self.appError = error
                    self.appState = .error
                }
            }
        } else {
            await MainActor.run {
                self.appState = .onboarding
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    static let shared = AppDelegate()
    var lightningClient: LightningNodeClient?

    func applicationWillTerminate(_ application: UIApplication) {
        try? lightningClient?.stop()
    }
}

public enum AppState {
    case onboarding
    case wallet
    case loading
    case error
}
