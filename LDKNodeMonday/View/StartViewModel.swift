//
//  StartViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import Foundation
import SwiftUI
import LightningDevKitNode

class StartViewModel: ObservableObject {
    @Published var networkColor = Color.gray
    @Published var isStarted: Bool = false
    @Published var errorMessage: MondayNodeError?

    func start() async throws {
        do {
            try await LightningNodeService.shared.start()
            DispatchQueue.main.async {
                self.isStarted = true
            }
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.errorMessage = .init(title: errorString.title, detail: errorString.detail)
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = .init(title: "Unexpected error", detail: error.localizedDescription)
            }
        }
        
    }
    
    func getColor() {
        let color = LightningNodeService.shared.networkColor
        DispatchQueue.main.async {
            self.networkColor = color
        }
    }
    
}
