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
                    .padding(.top, 60.0)
                
                if viewModel.payments.isEmpty {
                    Text("No Payments")
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.payments, id: \.self) { payment in
                            VStack {
                                HStack(alignment: .center, spacing: 15) {
                                    ZStack {
                                        Circle()
                                            .frame(width: 50.0, height: 50.0)
                                            .foregroundColor(viewModel.networkColor)
                                        switch payment.direction {
                                        case .inbound:
                                            Image(systemName: "arrow.down")
                                                .font(.subheadline)
                                                .foregroundColor(Color(uiColor: .systemBackground))
                                                .bold()
                                        case .outbound:
                                            Image(systemName: "arrow.up")
                                                .font(.subheadline)
                                                .foregroundColor(Color(uiColor: .systemBackground))
                                                .bold()
                                        }
                                    }
                                    VStack(alignment: .leading, spacing: 5.0) {
                                        HStack {
                                            let amountMsat = payment.amountMsat ?? 0
                                            let amountSats = amountMsat / 1000
                                            let amount = amountSats.formattedAmount()
                                            Text("\(amount) sats ")
                                                .font(.caption)
                                                .bold()
                                        }
                                        HStack {
                                            Text("Payment Hash")
                                            Text(payment.hash)
                                                .truncationMode(.middle)
                                                .lineLimit(1)
                                                .foregroundColor(.secondary)
                                        }
                                        .font(.caption)
                                        if let preimage = payment.preimage {
                                            HStack {
                                                Text("Preimage")
                                                Text(preimage)
                                                    .truncationMode(.middle)
                                                    .lineLimit(1)
                                                    .foregroundColor(.secondary)
                                            }
                                            .font(.caption)
                                        }
                                        VStack {
                                            switch LightningPaymentStatus(payment.status) {
                                            case .pending:
                                                Text("Pending")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            case .succeeded:
                                                Text("Succeeded")
                                                    .font(.caption)
                                                    .foregroundColor(.green)
                                            case .failed:
                                                Text("Failed")
                                                    .font(.caption)
                                                    .foregroundColor(.red)
                                            }
                                        }
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
