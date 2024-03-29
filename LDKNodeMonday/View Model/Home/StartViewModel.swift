//
//  StartViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import LDKNode
import SwiftUI

class StartViewModel: ObservableObject {
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    @Published var networkColor = Color.gray
    @Published var isStarted: Bool = false
    @Published var startViewError: MondayError?

    func start() async throws {
        do {
            try await LightningNodeService.shared.start()
            LightningNodeService.shared.listenForEvents()
            await MainActor.run {
                self.isStarted = true
            }
        } catch {
            await MainActor.run {
                self.startViewError = .init(
                    title: "Node Start Error",
                    detail: error.localizedDescription
                )
            }
            throw error
        }
    }

    func onboarding() {
        do {
            try KeyClient.live.deleteNetwork()
            try KeyClient.live.deleteEsplora()
            self.isOnboarding = true
        } catch _ as NodeError {
            self.isOnboarding = true
        } catch {
            self.isOnboarding = true
        }
    }

    func getColor() {
        let color = LightningNodeService.shared.networkColor
        DispatchQueue.main.async {
            self.networkColor = color
        }
    }

}
