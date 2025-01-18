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
    private let lightningClient: LightningNodeClient

    init(lightningClient: LightningNodeClient) {
        self.lightningClient = lightningClient
    }

    func listPayments() {
        self.payments = lightningClient.listPayments()
    }
}
