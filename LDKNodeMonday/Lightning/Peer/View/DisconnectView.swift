//
//  DisconnectView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/2/23.
//

import SwiftUI
import WalletUI

struct DisconnectView: View {
    @ObservedObject var viewModel: DisconnectViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDisconnectViewErrorAlert = false
    
    var body: some View {
        
        ZStack {
            Color(uiColor: UIColor.systemBackground)
            
            VStack {
                
                HStack {
                    Text("Node ID")
                    Text(viewModel.nodeId.description)
                        .truncationMode(.middle)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                    
                }
                .font(.system(.caption, design: .monospaced))
                .padding()
                
                Button("Disconnect Peer") {
                    
                    viewModel.disconnect()
                    
                    if showingDisconnectViewErrorAlert == false {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    
                    if showingDisconnectViewErrorAlert == true {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    
                }
                .buttonStyle(BitcoinOutlined(tintColor: viewModel.networkColor))
                
            }
            .padding()
            .alert(isPresented: $showingDisconnectViewErrorAlert) {
                Alert(
                    title: Text(viewModel.disconnectViewError?.title ?? "Unknown"),
                    message: Text(viewModel.disconnectViewError?.detail ?? ""),
                    dismissButton: .default(Text("OK")) {
                        viewModel.disconnectViewError = nil
                    }
                )
            }
            .onReceive(viewModel.$disconnectViewError) { errorMessage in
                if errorMessage != nil {
                    showingDisconnectViewErrorAlert = true
                }
            }
            .onAppear {
                viewModel.getColor()
            }
            
        }
        .ignoresSafeArea()
        
    }
    
}

struct DisconnectView_Previews: PreviewProvider {
    static var previews: some View {
        DisconnectView(viewModel: .init(nodeId: "03e39c737a691931dac0f9f9ee803f2ab08f7fd3bbb25ec08d9b8fdb8f51d3a8db"))
        DisconnectView(viewModel: .init(nodeId: "03e39c737a691931dac0f9f9ee803f2ab08f7fd3bbb25ec08d9b8fdb8f51d3a8db"))
            .environment(\.colorScheme, .dark)
    }
}
