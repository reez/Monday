//
//  PaymentKind+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 3/15/24.
//

import LDKNode

extension PaymentKind {
    var preimageAsString: String? {
        switch self {
        case .onchain:
            return nil
        case .bolt11(let hash, let preimage, let secret):
            return preimage
        case .bolt11Jit(let hash, let preimage, let secret, let lspFeeLimits):
            return preimage
        case .spontaneous(let hash, let preimage):
            return preimage
        }
    }
}
