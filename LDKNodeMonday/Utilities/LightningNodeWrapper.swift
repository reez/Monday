//
//  LightningNodeWrapper.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 6/21/23.
//

import Foundation
import LDKNode

enum LightningPaymentStatus {
    case pending
    case succeeded
    case failed
    
    init(_ paymentStatus: PaymentStatus) {
        switch paymentStatus {
        case .pending:
            self = .pending
        case .succeeded:
            self = .succeeded
        case .failed:
            self = .failed
        }
    }
}
