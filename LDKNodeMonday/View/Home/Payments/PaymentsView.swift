//
//  PaymentsView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 6/20/23.
//

import SwiftUI

struct PaymentsView: View {
    @ObservedObject var viewModel: PaymentsViewModel

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

                if viewModel.payments.isEmpty {
                    Text("No Payments")
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                } else {
                    PaymentsListView(payments: viewModel.payments)
                        .refreshable {
                            viewModel.listPayments()
                        }
                }

            }
            .onAppear {
                viewModel.listPayments()
            }

        }

    }

}

#Preview {
    PaymentsView(viewModel: .init())
}
