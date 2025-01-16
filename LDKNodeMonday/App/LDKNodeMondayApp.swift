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

    @State private var appState = AppState.loading
    @State private var appError: Error?
    @State private var navigationPath = NavigationPath()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationPath) {
                switch appState {
                case .onboarding:
                    OnboardingView(viewModel: .init(appState: $appState))
                case .wallet:
                    BitcoinView(
                        viewModel: .init(priceClient: .live),
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

        do {
            backupInfo = try KeyClient.live.getBackupInfo()
        } catch let error {
            debugPrint(error)  // TODO: Show error on relevant screen, unless this is thrown if no seed has been saved
            await MainActor.run {
                self.appError = error
                self.appState = .error
            }
        }

        if backupInfo != nil {
            do {
                // TODO: .start could take parameters from backupInfo (seed, network, url, lsp)
                try await LightningNodeService.shared.start()
                LightningNodeService.shared.listenForEvents()
                await MainActor.run {
                    self.appState = .wallet
                }
            } catch let error {
                debugPrint(error)
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
    func applicationWillTerminate(_ application: UIApplication) {
        try? LightningNodeService.shared.stop()
    }
}

public enum AppState {
    case onboarding
    case wallet
    case loading
    case error
}
