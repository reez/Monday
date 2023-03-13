//
//  SendView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/28/23.
//

import SwiftUI
import LightningDevKitNode

class SendViewModel: ObservableObject {
    
    func sendSpontaneousPayment() {
        LightningNodeService.shared.sendSpontaneousPayment(amountMsat: UInt64(1002), nodeId: "03a529eea4bb467d7f300e48e1677eb7bccaa124c2b6f259915b099fcb82a9650c")
    }
    
    func sendPayment() {
        let invoice = Invoice(stringLiteral: "lnbcrt500u1pjqz9yrpp56873w23uypdl40ff7xw653527dj2fgsm9l5s42myxhhg48n4w5nqdqqcqzpgsp577ky2wx5yz78jsmxfc0dxlfnejd8z57pd9h4x4pcrxxhzgwjjy9s9qyyssqf3lkt7zj66mwtc9l2ym6gj8t88ntjnwhz0gdsgmtucugqy5w3q3r0mc9rxxs9e474xh09et4a2v5e6mwjydtuglayw9mvk8nqpefflqqsq7k5g")
        LightningNodeService.shared.sendPayment(invoice: invoice)
    }
    
}

struct SendView: View {
    @ObservedObject var viewModel: SendViewModel
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: UIColor.systemBackground)
                
                VStack {
                    
                    Button {
                        viewModel.sendSpontaneousPayment()
                    } label: {
                        Text("Spontaneous")
                    }
                    .padding()
                    
                    Button {
                        viewModel.sendPayment()
                    } label: {
                        Text("Invoice")
                    }
                    .padding()
                    
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
