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
                
                Text("Payment History")
                    .bold()
                    .padding(.top, 60.0)
                
                if viewModel.payments.isEmpty {
                    Text("No Payments")
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                } else {
                    PaymentsListItemView(payments: viewModel.payments, networkColor: viewModel.networkColor)
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
        PaymentsView(viewModel: .init())
        PaymentsView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
