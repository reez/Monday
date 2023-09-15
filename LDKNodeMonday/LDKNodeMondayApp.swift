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
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    
    init() {
        do {
            try LightningNodeService.shared.loadWallet() //try bdkService.loadWallet()
        } catch {
            print("BDKSwiftExampleWalletApp error: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            if isOnboarding {
                OnboardingView(viewModel: .init())
            } else {
                TabHomeView(viewModel: .init())
            }
        }
    }

//    var body: some Scene {
//        WindowGroup {
//            StartView(viewModel: .init())
//        }
//    }

}

class AppDelegate: NSObject, UIApplicationDelegate {
    func applicationWillTerminate(_ application: UIApplication) {
        try? LightningNodeService.shared.stop()
    }
}
