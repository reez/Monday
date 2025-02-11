//
//  PaymentsView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 6/20/23.
//

import LDKNode
import SwiftUI

struct PaymentsView: View {
    @Binding var transactions: [PaymentDetails]

    var body: some View {
        VStack {
            if transactions.isEmpty {
                Spacer()
                Text("No activity yet")
                    .font(.subheadline)
                Spacer()
            } else {
                PaymentsListView(payments: transactions)
                    .refreshable {
                        // TODO: expose getTransactions() from BitcoinViewModel
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
