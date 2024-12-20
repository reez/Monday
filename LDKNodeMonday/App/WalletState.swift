//
//  WalletState.swift
//  LDKNodeMonday
//
//  Created by Daniel Nordh on 20/12/2024.
//

import Foundation
import LDKNode
import SwiftUI

@Observable
public class WalletState {

    public var network = Network.signet
    public var server = EsploraServer.mutiny_signet
    public var appNavigation = AppNavigation.loading
    public var appError: Error?

    private var keyClient: KeyClient

    public init(keyClient: KeyClient) {
        self.keyClient = keyClient
    }

    public func start() async {
        var backupInfo: BackupInfo?
        do {
            backupInfo = try KeyClient.live.getBackupInfo()
        } catch let error {
            debugPrint(error)  // TODO: Show error on relevant screen, unless this is thrown if no seed has been saved
            self.appError = error
        }

        if backupInfo == nil {
            self.appNavigation = .onboarding
        } else {
            do {
                try await LightningNodeService.shared.start()
                LightningNodeService.shared.listenForEvents()
                await MainActor.run {
                    self.appNavigation = .wallet
                }
            } catch let error {
                debugPrint(error)  // TODO: Show error on relevant screen
                self.appError = error
            }
        }
    }
}

public enum AppNavigation {
    case onboarding
    case wallet
    case loading
    case error  // Currently unused in App()
}
