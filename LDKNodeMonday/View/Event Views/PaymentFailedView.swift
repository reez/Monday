//
//  PaymentFailedView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/2/23.
//

import SwiftUI

struct PaymentFailedView: View {
    let paymentFailed: PaymentFailed
    
    var body: some View {
        
        VStack(spacing: 10) {
        
            HStack {
                Image(systemName: "questionmark")
                Text("Payment Failed")
            }
            
            HStack {
                Text("Payment Hash:")
                Text(paymentFailed.paymentHash.description)
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
            }
            
        }
        .font(.system(.caption, design: .monospaced))
        .padding()
        
    }
}

struct PaymentFailedView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentFailedView(
            paymentFailed: .init(
                paymentHash: "hash2ff575465c3aed395d5eaafbf0cd69bb1397b52dd34adfcc558a533ef62363a8"
            )
        )
    }
}
