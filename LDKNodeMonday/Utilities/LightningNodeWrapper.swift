//
//  LightningNodeWrapper.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 6/21/23.
//

import Foundation
import LDKNode

// Wrapper enum that maps to the Rust enum
enum PaymentStatusWrapper {
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
