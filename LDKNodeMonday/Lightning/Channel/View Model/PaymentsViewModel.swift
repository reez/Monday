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
    
    func listPayments() {
        self.payments = LightningNodeService.shared.listPayments()
    }
    
}
