//
//  PaymentsViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 6/20/23.
//

import Foundation
import LDKNode
import SwiftUI

class PaymentsViewModel: ObservableObject {
    @Published var payments: [PaymentDetails] = []
    @Published var networkColor = Color.gray
    
    func listPayments() {
        self.payments = LightningNodeService.shared.listPayments()
    }
    
    func getColor() {
        let color = LightningNodeService.shared.networkColor
        DispatchQueue.main.async {
            self.networkColor = color
        }
    }
    
}
