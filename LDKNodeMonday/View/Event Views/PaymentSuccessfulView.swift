//
//  PaymentSuccessfulView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/2/23.
//

import SwiftUI

struct PaymentSuccessfulView: View {
    let paymentSuccessful: PaymentSuccessful
    
    var body: some View {
        
        VStack(spacing: 10) {
            
            HStack {
                Image(systemName: "checkmark")
                Text("Payment Successful")
            }
            
            HStack {
                Text("Payment Hash:")
                Text(paymentSuccessful.paymentHash.description)
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
            }
            
        }
        .font(.system(.caption, design: .monospaced))
        .padding()
        
    }
    
}

struct PaymentSuccessfulView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentSuccessfulView(paymentSuccessful: .init(paymentHash: ""))
    }
}
