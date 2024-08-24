//
//  ReceiveOption.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 3/4/24.
//

import Foundation

enum ReceiveOption: String, CaseIterable, Identifiable {
    //    case bolt11Zero = "Bolt11 0"
    //    case bolt11 = "Bolt11"
    case bolt11JIT = "Bolt11 JIT"
    //    case bolt12Zero = "Bolt12 0"
    //    case bolt12 = "Bolt12"
    //    case bitcoin = "Address"
    case bip21 = "BIP21"

    var id: Self { self }
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
