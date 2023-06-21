//
//  StartViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import SwiftUI
import LDKNode

class StartViewModel: ObservableObject {
    @Published var networkColor = Color.gray
    @Published var isStarted: Bool = false
    @Published var startViewError: MondayError?
    
    func start() async throws {
        do {
            try await LightningNodeService.shared.start()
            DispatchQueue.main.async {
                self.isStarted = true
            }
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.startViewError = .init(title: errorString.title, detail: errorString.detail)
            }
        } catch {
            DispatchQueue.main.async {
                self.startViewError = .init(title: "Unexpected error", detail: error.localizedDescription)
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
