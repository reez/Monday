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
    @Binding var displayBalanceType: DisplayBalanceType

    var body: some View {
        VStack {
            if transactions.isEmpty {
                Spacer()
                Text("No activity yet")
                    .font(.subheadline)
                Spacer()
            } else {
                PaymentsListView(payments: $transactions, displayBalanceType: $displayBalanceType)
                    .refreshable {
                        // TODO: expose getTransactions() from BitcoinViewModel
                    }
            }
        }
    }
}

#if DEBUG
    #Preview {
        PaymentsView(transactions: .constant(mockPayments), displayBalanceType: .constant(.fiatSats))
    }
#endif
