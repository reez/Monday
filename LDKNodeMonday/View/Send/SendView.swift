//
//  SendView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/28/23.
//

import SwiftUI
import LightningDevKitNode
import WalletUI

class SendViewModel: ObservableObject {
    @Published var invoice: PublicKey = ""
}

struct SendView: View {
    @ObservedObject var viewModel: SendViewModel
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: UIColor.systemBackground)
                
                VStack {
                    
                    VStack(alignment: .leading) {
                        
                        Text("Invoice")
                            .bold()
                        
                        TextField("lnbc10u1pwz...8f8r9ckzr0r", text: $viewModel.invoice)
                            .frame(height: 48)
                            .truncationMode(.middle)
                            .padding(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18))
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(lineWidth: 1.0)
                                    .foregroundColor(.secondary)
                            )
                        
                    }
                    .padding()
                    
                    NavigationLink(
                        destination:
                            SendConfirmationView(
                                viewModel: .init(
                                    invoice: viewModel.invoice
                                )
                            )
                    ) {
                        Text("Send")
                    }
                    .buttonStyle(BitcoinOutlined())
                    
                }
                .padding()
                .navigationTitle("Send")
                
            }
            .ignoresSafeArea()
            
        }
        
    }
}

struct SendView_Previews: PreviewProvider {
    static var previews: some View {
        SendView(viewModel: .init())
        SendView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
