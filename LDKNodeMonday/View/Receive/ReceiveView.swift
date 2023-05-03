//
//  ReceiveView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/1/23.
//

import SwiftUI

import LightningDevKitNode
import WalletUI

class ReceiveViewModel: ObservableObject {
    @Published var invoice: PublicKey = ""
    @Published var amountMsat: String = "" // TODO: make minimum 1/10/1000?
    
    func receivePayment(amountMsat: UInt64, description: String, expirySecs: UInt32) {
        guard let invoice = LightningNodeService.shared.receivePayment(
            amountMsat: amountMsat,
            description: description,
            expirySecs: expirySecs
        ) else { return }
        self.invoice = invoice
    }
    
    func clearInvoice() {
        self.invoice = ""
    }
    
}

struct ReceiveView: View {
    @ObservedObject var viewModel: ReceiveViewModel
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: UIColor.systemBackground)
                
                VStack {
                    
                    VStack(alignment: .leading) {
                        
                        Text("Amount (mSat)")
                            .bold()
                        
                        TextField("125000", text: $viewModel.amountMsat)
                            .frame(height: 48)
                            .padding(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18))
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(lineWidth: 1.0)
                                    .foregroundColor(.secondary)
                            )
                        
                    }
                    .padding()
                    
                    Button("Create Invoice") {
                        viewModel.receivePayment(
                            amountMsat: UInt64(viewModel.amountMsat) ?? 0,
                            description: "LDKNodeMonday",
                            expirySecs: UInt32(3600)
                        )
                    }
                    .buttonStyle(BitcoinOutlined())
                    .padding()
                    
                    
                    
                    if viewModel.invoice != "" {
                        
                        HStack(alignment: .center) {
                            
                            ZStack {
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 50.0, height: 50.0)
//                                    .foregroundColor(.orange)
                                    .foregroundColor(LightningNodeService.shared.networkColor)
                                
                                Image(systemName: "bolt.fill")
                                    .font(.title)
                                    .foregroundColor(Color(uiColor: .systemBackground))
                                    .bold()
                                
                            }
                            
                            VStack(alignment: .leading, spacing: 5.0) {
                                
                                Text("Lightning Network")
                                    .font(.caption)
                                    .bold()
                                
                                Text(viewModel.invoice)
                                    .font(.caption)
                                    .truncationMode(.middle)
                                    .lineLimit(1)
                                    .foregroundColor(.secondary)
                                
                            }
                            
                            Spacer()
                            
                            Button {
                                UIPasteboard.general.string = viewModel.invoice
                            } label: {
                                HStack {
                                    Image(systemName: "doc.on.doc")
                                        .font(.subheadline)
                                }
                                .bold()
                                .foregroundColor(LightningNodeService.shared.networkColor)

                            }
                            
                        }
                        .padding()
                        
                        
                        Button("Clear Invoice") {
                            viewModel.clearInvoice()
                        }
                        .buttonStyle(BitcoinOutlined())
                        .padding()
                        
                    }
                    
                }
                .padding()
                .navigationTitle("Receive")
                
            }
            .ignoresSafeArea()
            
        }
        
    }
    
}

struct ReceiveView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiveView(viewModel: .init())
        ReceiveView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
