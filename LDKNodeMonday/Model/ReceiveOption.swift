//
//  ReceiveOption.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 3/4/24.
//

import Foundation

enum ReceiveOption: String, CaseIterable, Identifiable {
    var id: Self { self }

    case bolt11JIT = "BOLT11 JIT"
    case bip21 = "BIP21"
}

extension ReceiveOption {
    var systemImageName: String {
        switch self {
        case .bolt11JIT:
            return "bolt"
        default:
            return "qrcode"
        }
    }
}
