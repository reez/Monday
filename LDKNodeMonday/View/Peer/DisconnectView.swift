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
    
    init(nodeId: PublicKey) {
        self.nodeId = nodeId
    }
    
    func disconnect() {
        LightningNodeService.shared.disconnect(nodeId: self.nodeId)
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
                .buttonStyle(BitcoinOutlined())
                
            }
            
        }
        
    }
    
}

struct DisconnectView_Previews: PreviewProvider {
    static var previews: some View {
        DisconnectView(viewModel: .init(nodeId: "someID"))
        DisconnectView(viewModel: .init(nodeId: "someID"))
            .environment(\.colorScheme, .dark)
    }
}
