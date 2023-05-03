//
//  PaymentReceivedView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/2/23.
//

import SwiftUI

struct PaymentReceivedView: View {
    let paymentReceived: PaymentReceived
    
    var body: some View {
        
        VStack(spacing: 10) {
            
            HStack {
                Image(systemName: "arrow.down")
                Text("Payment Received")
            }
            
            HStack {
                Text("Payment Hash:")
                Text(paymentReceived.paymentHash.description)
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Amount (msat):")
                Text("\(paymentReceived.amountMsat)")
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
            }
        }
        .font(.system(.caption, design: .monospaced))
        .padding()
        
    }
    
}

struct PaymentReceivedView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentReceivedView(
            paymentReceived: .init(
                paymentHash: "hash2ff575465c3aed395d5eaafbf0cd69bb1397b52dd34adfcc558a533ef62363a8",
                amountMsat: UInt64(21000)
            )
        )
    }
}
