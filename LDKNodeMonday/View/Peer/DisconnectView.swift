//
//  DisconnectView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/2/23.
//

import SwiftUI
import LightningDevKitNode
import WalletUI

class DisconnectViewModel: ObservableObject {
    @Published var nodeId: PublicKey
    @Published var networkColor = Color.gray

    init(nodeId: PublicKey) {
        self.nodeId = nodeId
    }
    
    func disconnect() {
        LightningNodeService.shared.disconnect(nodeId: self.nodeId)
    }
    
    func getColor() {
        let color = LightningNodeService.shared.networkColor
        self.networkColor = color
    }
    
}
struct DisconnectView: View {
    @ObservedObject var viewModel: DisconnectViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        ZStack {
            Color(uiColor: UIColor.systemBackground)
            
            VStack {
                
                HStack {
                    
                    Text("Node ID:")
                    
                    Text(viewModel.nodeId.description)
                        .truncationMode(.middle)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                    
                }
                .font(.system(.caption, design: .monospaced))
                .padding()
                
                Button("Disconnect Peer") {
                    viewModel.disconnect()
                }
                .buttonStyle(BitcoinOutlined(tintColor: viewModel.networkColor))
                
            }
            .padding()
            // navigation title?
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
