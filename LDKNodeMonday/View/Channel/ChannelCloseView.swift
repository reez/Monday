//
//  ChannelCloseView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/2/23.
//

import SwiftUI
import LightningDevKitNode
import WalletUI

class ChannelCloseViewModel: ObservableObject {
    @Published var channel: ChannelDetails
    
    init(channel: ChannelDetails) {
        self.channel = channel
    }
    
    func close() {
        LightningNodeService.shared.closeChannel(
            channelId: self.channel.channelId,
            counterpartyNodeId: self.channel.counterparty
        )
    }
    
}

struct ChannelCloseView: View {
    @ObservedObject var viewModel: ChannelCloseViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        ZStack {
            Color(uiColor: UIColor.systemBackground)
            
            VStack {
                
                VStack(spacing: 10) {
                    
                    HStack {
                        
                        Text("Channel ID:")
                        
                        Text(viewModel.channel.channelId.description)
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                        
                    }
                    
                    HStack {
                        
                        Text("Counterparty Node ID:")
                        
                        Text(viewModel.channel.counterparty.description)
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                        
                    }
                    
                }
                .font(.system(.caption, design: .monospaced))
                .padding()
                
                Button("Close Channel") {
                    viewModel.close()
                }
                .buttonStyle(BitcoinOutlined())
                
            }
            
        }
        
    }
}

// channelId: "2ff575465c3aed395d5eaafbf0cd69bb1397b52dd34adfcc558a533ef62363a8", counterpartyNodeId: "0204ad94e0ac2e1bba3f03edfbc95aa5a7d3114a12a22610a7adba123f1f01d437")
//struct ChannelCloseView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChannelCloseView(viewModel: .init(channel: .ini))
//    }
//}
