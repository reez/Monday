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

let mockPayments: [PaymentDetails] = [
    .init(
        id: "1",
        kind: .bolt11(hash: "hash1", preimage: nil, secret: nil),
        amountMsat: nil,
        direction: .inbound,
        status: .succeeded,
        latestUpdateTimestamp: 1_718_841_600
    ),
    .init(
        id: "2",
        kind: .bolt11(hash: "hash2", preimage: nil, secret: nil),
        amountMsat: nil,
        direction: .inbound,
        status: .pending,
        latestUpdateTimestamp: 1_718_841_600
    ),
    .init(
        id: "3",
        kind: .bolt11(hash: "hash3", preimage: nil, secret: nil),
        amountMsat: nil,
        direction: .inbound,
        status: .failed,
        latestUpdateTimestamp: 1_718_841_600
    )
]
