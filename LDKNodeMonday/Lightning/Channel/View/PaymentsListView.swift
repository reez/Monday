//
//  PaymentsListView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 6/20/23.
//

import SwiftUI

struct PaymentsListView: View {
    @ObservedObject var viewModel: PaymentsListViewModel

    var body: some View {
        
        ZStack {
            Color(uiColor: UIColor.systemBackground)

            VStack {
                
                Text("Payment History")
                    .bold()
                    .padding(.top, 40.0)
                
                if viewModel.payments.isEmpty {
                    Text("No Payments")
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.payments, id: \.self) { payment in //ForEach(viewModel.payments.sorted(by: { $0.status > $1.status }), id: \.self) { payment in
                            
                            VStack {
                                HStack(alignment: .center, spacing: 15) {
                                    ZStack {
                                        Circle()
                                            .frame(width: 50.0, height: 50.0)
                                            .foregroundColor(viewModel.networkColor)
                                        Image(systemName: "bolt.fill")
                                            .font(.subheadline)
                                            .foregroundColor(Color(uiColor: .systemBackground))
                                            .bold()
                                    }
                                    VStack(alignment: .leading, spacing: 5.0) {
                                        let amountMsat = payment.amountMsat ?? 0
                                        let amountSats = amountMsat / 1000
                                        let amount = amountSats.formattedAmount()
                                        Text("\(amount) sats ")
                                            .font(.caption)
                                            .bold()
                                        HStack {
                                            Text("Payment Hash")
                                            Text(payment.hash)
                                                .truncationMode(.middle)
                                                .lineLimit(1)
                                                .foregroundColor(.secondary)
                                        }
                                        .font(.caption)
                                    }
                                    Spacer()
                                }
                                .padding()
                            }
                            
                        }
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        viewModel.listPayments()
                    }
                }
                
            }
            .onAppear {
                viewModel.listPayments()
                viewModel.getColor()
            }
            
        }
        
    }
    
}

struct PaymentsListView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsListView(viewModel: .init())
        PaymentsListView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
