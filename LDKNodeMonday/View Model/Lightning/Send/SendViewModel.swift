//
//  SendViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import LDKNode
import SwiftUI

class SendViewModel: ObservableObject {
    @Published var invoice: PublicKey = "" {
        didSet {
            invoice = invoice.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    @Published var networkColor = Color.gray
    @Published var parseError: MondayError?

    func getColor() {
        let color = LightningNodeService.shared.networkColor
        DispatchQueue.main.async {
            self.networkColor = color
        }
    }

}
