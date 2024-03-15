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
        case .bolt11(_, let preimage, _),
            .bolt11Jit(_, let preimage, _, _),
            .bolt12(_, let preimage, _),
            .spontaneous(_, let preimage):
            return preimage
        case .onchain:
            return nil
        }
    }
}
