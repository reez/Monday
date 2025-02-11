//
//  PaymentsView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 6/20/23.
//

import SwiftUI
import LDKNode

struct PaymentsView: View {
    @Binding var transactions: [PaymentDetails]

    var body: some View {

        ZStack {
            Color(uiColor: UIColor.systemBackground)

            VStack {

                HStack {
                    Text("Payment History")
                        .font(.title)
                        .bold()
                    Spacer()
                }
                .padding()
                .padding(.top, 40.0)

                Spacer()

                if transactions.isEmpty {
                    Text("No Payments")
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                } else {
                    PaymentsListView(payments: transactions)
                }

            }
        }

    }

}

#if DEBUG
    #Preview {
        PaymentsView(transactions: .constant(mockPayments))
    }
#endif
