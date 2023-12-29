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

    var body: some Scene {
        WindowGroup {
            StartView(viewModel: .init())
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        LightningNodeService.shared.listenForEvents()
        return true
    }
    func applicationWillTerminate(_ application: UIApplication) {
        try? LightningNodeService.shared.stop()
    }
}
