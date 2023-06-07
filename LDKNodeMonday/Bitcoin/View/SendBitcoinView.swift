//
//  SendBitcoinView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 6/7/23.
//

import SwiftUI

struct SendBitcoinView: View {
    @ObservedObject var viewModel: SendBitcoinViewModel
    @State private var showingBitcoinViewErrorAlert = false
    
    var body: some View {
        
        ZStack {
            Color(uiColor: UIColor.systemBackground)

            VStack {
                Text("Hello, Send Bitcoin!")
                // QR Camera Button
                // Paste Button
                // TextField
                // Label for Amount
            }
        }
        .ignoresSafeArea()
        
    }
}

struct SendBitcoinView_Previews: PreviewProvider {
    static var previews: some View {
        SendBitcoinView(viewModel: .init())
        SendBitcoinView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
