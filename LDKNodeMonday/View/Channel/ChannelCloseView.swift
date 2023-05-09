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
    @Published var networkColor = Color.gray

    init(channel: ChannelDetails) {
        self.channel = channel
    }
    
    func close() {
        LightningNodeService.shared.closeChannel(
            channelId: self.channel.channelId,
            counterpartyNodeId: self.channel.counterpartyNodeId
        )
    }
    
    func getColor() {
        let color = LightningNodeService.shared.networkColor
        self.networkColor = color
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
                        
                        Text(viewModel.channel.counterpartyNodeId.description)
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                        
                    }
                    
                    HStack {
                        
                        Text("Channel Value Satoshis:")
                        
                        Text(viewModel.channel.channelValueSatoshis.description)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                        
                    }
                    
                    HStack {
                        
                        Text("Balance mSat:")
                        
                        Text(viewModel.channel.balanceMsat.description)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                        
                    }
                    
                    HStack {
                        
                        Text("Outbound Capacity (mSat):")
                        
                        Text(viewModel.channel.outboundCapacityMsat.description)
                            .foregroundColor(.secondary)
                        
                    }
                    
                    HStack {
                        
                        Text("Inbound Capacity (mSat):")
                        
                        Text(viewModel.channel.inboundCapacityMsat.description)
                            .foregroundColor(.secondary)
                        
                    }
                    
                    
                    if let confirm = viewModel.channel.confirmations {
                        HStack {
                            
                            Text("Confirmations:")
                            
                            Text(confirm.description)
                                .foregroundColor(.secondary)
                            
                        }
                    }
                    
                    HStack {
                        
                        Text("Is Channel Ready:")
                        
                        Text(viewModel.channel.isChannelReady.description)
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                        
                    }
                    
                    HStack {
                        
                        Text("Is Usable:")
                        
                        Text(viewModel.channel.isUsable.description)
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                        
                    }
                    
                }
                .font(.system(.caption, design: .monospaced))
                .padding()
                
                Button("Close Channel") {
                    viewModel.close()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
                .buttonStyle(BitcoinOutlined(tintColor: viewModel.networkColor))
                
            }
            .padding()
            .onAppear {
                viewModel.getColor()
            }
            
        }
        .ignoresSafeArea()
        
    }
}

// channelId: "2ff575465c3aed395d5eaafbf0cd69bb1397b52dd34adfcc558a533ef62363a8", counterpartyNodeId: "0204ad94e0ac2e1bba3f03edfbc95aa5a7d3114a12a22610a7adba123f1f01d437")
//struct ChannelCloseView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChannelCloseView(viewModel: .init(channel: .init(channelId: <#T##ChannelId#>, counterpartyNodeId: <#T##PublicKey#>, fundingTxo: <#T##OutPoint?#>, shortChannelId: <#T##UInt64?#>, outboundScidAlias: <#T##UInt64?#>, inboundScidAlias: <#T##UInt64?#>, channelValueSatoshis: <#T##UInt64#>, unspendablePunishmentReserve: <#T##UInt64?#>, userChannelId: <#T##UserChannelId#>, balanceMsat: <#T##UInt64#>, outboundCapacityMsat: <#T##UInt64#>, inboundCapacityMsat: <#T##UInt64#>, confirmationsRequired: <#T##UInt32?#>, confirmations: <#T##UInt32?#>, isOutbound: <#T##Bool#>, isChannelReady: <#T##Bool#>, isUsable: <#T##Bool#>, isPublic: <#T##Bool#>, cltvExpiryDelta: <#T##UInt16?#>)))
//    }
//}
