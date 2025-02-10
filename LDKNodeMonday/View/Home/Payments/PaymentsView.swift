//
//  PaymentsView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 6/20/23.
//

import SwiftUI

struct PaymentsView: View {
    @Binding var walletClient: WalletClient

    var body: some View {
        VStack {
            if walletClient.transactions.isEmpty {
                Spacer()
                Text("No activity yet")
                    .font(.subheadline)
                Spacer()
            } else {
                PaymentsListView(payments: walletClient.transactions)
                    .refreshable {
                        walletClient.updateTransactions()
                    }
            }
        }
        .onAppear {
            walletClient.updateTransactions()
        }
    }
}

#if DEBUG
    #Preview {
        PaymentsView(
            walletClient: .constant(WalletClient(mode: .mock))
        )
    }
#endif
