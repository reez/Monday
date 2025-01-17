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
    @Published var seed: BackupInfo = .init(mnemonic: "mock seed words", network: Network.signet, server: EsploraServer.mutiny_signet)
    @Published var seedViewError: MondayError?

    func getSeed() {
        do {
            let seed = try LightningNodeService.shared.getBackupInfo()
            self.seed = seed
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.seedViewError = .init(title: errorString.title, detail: errorString.detail)
            }
        } catch {
            DispatchQueue.main.async {
                self.seedViewError = .init(
                    title: "Unexpected error",
                    detail: error.localizedDescription
                )
            }
        }
    }

}
