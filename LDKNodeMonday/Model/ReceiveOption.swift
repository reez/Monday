//
//  ReceiveOption.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 3/4/24.
//

import Foundation

enum ReceiveOption: String, CaseIterable, Identifiable {
    case zeroInvoice = "Zero"
    case amountInvoice = "Amount"
    case jitInvoice = "JIT"
    case bolt12 = "Bolt12"
    case bitcoin = "Address"

    var id: Self { self }
}

extension ReceiveOption {
    var systemImageName: String {
        switch self {
        case .bitcoin:
            return "bitcoinsign"
        default:
            return "bolt"
        }
    }
}
