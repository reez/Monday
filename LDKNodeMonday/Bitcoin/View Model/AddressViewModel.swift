//
//  AddressViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import SwiftUI
import LDKNode

class AddressViewModel: ObservableObject {
    @Published var address: String = ""
    @Published var addressViewError: MondayError?
    @Published var networkColor = Color.gray
    @Published var isAddressFinished: Bool = false
    
    func newFundingAddress() async {
        do {
            let address = try await LightningNodeService.shared.newFundingAddress()
            DispatchQueue.main.async {
                self.address = address
                self.isAddressFinished = true
            }
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.addressViewError = .init(title: errorString.title, detail: errorString.detail)
            }
        } catch {
            DispatchQueue.main.async {
                self.addressViewError = .init(title: "Unexpected error", detail: error.localizedDescription)
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
