//
//  StartViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import LDKNode
import SwiftUI

class StartViewModel: ObservableObject {
    @Published var networkColor = Color.gray
    @Published var isStarted: Bool = false
    @Published var startViewError: MondayError?
    @AppStorage("isOnboarding") var isOnboarding: Bool?

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
            // Delete network and URL settings using KeyClient
            try KeyClient.live.deleteNetwork()
            try KeyClient.live.deleteEsplora()
            // ... then set isOnboarding to true
            self.isOnboarding = true
            // ... which should send you back to OnboardingView
        } catch _ as NodeError {
            self.isOnboarding = true
            // ... which should send you back to OnboardingView
        } catch {
            self.isOnboarding = true
            // ... which should send you back to OnboardingView
        }
    }

    func getColor() {
        let color = LightningNodeService.shared.networkColor
        DispatchQueue.main.async {
            self.networkColor = color
        }
    }

}
