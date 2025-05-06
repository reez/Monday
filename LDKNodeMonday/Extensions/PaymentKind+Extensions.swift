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
        case .bolt11(_, let preimage, _):
            return preimage
        case .bolt11Jit(_, let preimage, _, _, _):
            return preimage
        case .spontaneous(_, let preimage):
            return preimage
        case .bolt12Offer(hash: _, let preimage, secret: _, offerId: _, payerNote: _, quantity: _):
            return preimage
        case .bolt12Refund(hash: _, let preimage, secret: _, payerNote: _, quantity: _):
            return preimage
        }
    }
}
