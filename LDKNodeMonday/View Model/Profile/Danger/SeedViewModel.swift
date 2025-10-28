//
//  SeedViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 1/5/24.
//

import Foundation
import LDKNode
import SwiftUI

class SeedViewModel: ObservableObject {
    @Published var seed: BackupInfo = .init(
        mnemonic: "mock seed words",
        networkString: Network.signet.description,
        serverURL: EsploraServer.mutiny_signet.url
    )
    @Published var seedViewError: MondayError?
    private let keyClient: KeyClient
    private let lightningClient: LightningNodeClient?

    init(keyClient: KeyClient, lightningClient: LightningNodeClient? = nil) {
        self.keyClient = keyClient
        self.lightningClient = lightningClient
    }

    func getSeed() {
        do {
            let seed = try keyClient.getBackupInfo()
            DispatchQueue.main.async {
                self.seed = seed
            }
        } catch {
            if let lightningClient {
                do {
                    let seed = try lightningClient.getBackupInfo()
                    DispatchQueue.main.async {
                        self.seed = seed
                    }
                    return
                } catch let nodeError as NodeError {
                    let errorString = handleNodeError(nodeError)
                    DispatchQueue.main.async {
                        self.seedViewError = .init(
                            title: errorString.title,
                            detail: errorString.detail
                        )
                    }
                    return
                } catch {
                    // Fall through to generic error handling below.
                }
            }
            DispatchQueue.main.async {
                self.seedViewError = .init(
                    title: "Recovery phrase unavailable",
                    detail: error.localizedDescription
                )
            }
        }
    }
}
