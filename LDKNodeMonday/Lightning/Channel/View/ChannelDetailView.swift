//
//  ChannelCloseView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/2/23.
//

import SwiftUI
import WalletUI

struct ChannelDetailView: View {
    @ObservedObject var viewModel: ChannelDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingChannelDetailViewErrorAlert = false
    @Binding var refreshFlag: Bool
    
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
                        Text("Balance (msat):")
                        Text(viewModel.channel.balanceMsat.description)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Outbound Capacity (msat):")
                        Text(viewModel.channel.outboundCapacityMsat.description)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Inbound Capacity (msat):")
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
                    refreshFlag = true
                    if showingChannelDetailViewErrorAlert == false {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .buttonStyle(BitcoinOutlined(tintColor: viewModel.networkColor))
                
            }
            .padding()
            .alert(isPresented: $showingChannelDetailViewErrorAlert) {
                Alert(
                    title: Text(viewModel.channelDetailViewError?.title ?? "Unknown"),
                    message: Text(viewModel.channelDetailViewError?.detail ?? ""),
                    dismissButton: .default(Text("OK")) {
                        viewModel.channelDetailViewError = nil
                    }
                )
            }
            .onReceive(viewModel.$channelDetailViewError) { errorMessage in
                if errorMessage != nil {
                    showingChannelDetailViewErrorAlert = true
                }
            }
            .onAppear {
                viewModel.getColor()
            }
            
        }
        .ignoresSafeArea()
        
    }
}

struct ChannelCloseView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ChannelDetailView(
            viewModel: .init(
                channel: .init(
                    channelId: "2ff575465c3aed395d5eaafbf0cd69bb1397b52dd34adfcc558a533ef62363a8",
                    counterpartyNodeId: "0204ad94e0ac2e1bba3f03edfbc95aa5a7d3114a12a22610a7adba123f1f01d437",
                    fundingTxo: nil,
                    shortChannelId: nil,
                    outboundScidAlias: nil,
                    inboundScidAlias: nil,
                    channelValueSatoshis: UInt64(1),
                    unspendablePunishmentReserve: nil,
                    userChannelId: "2ff575465c3aed395d5eaafbf0cd69bb1397b52dd34adfcc558a533ef62363a8",
                    balanceMsat: UInt64(2),
                    outboundCapacityMsat: UInt64(3),
                    inboundCapacityMsat: UInt64(4),
                    confirmationsRequired: nil,
                    confirmations: nil,
                    isOutbound: true,
                    isChannelReady: true,
                    isUsable: false,
                    isPublic: true,
                    cltvExpiryDelta: nil
                )
            ),
            refreshFlag: .constant(false)
        )
        
        ChannelDetailView(
            viewModel: .init(
                channel: .init(
                    channelId: "2ff575465c3aed395d5eaafbf0cd69bb1397b52dd34adfcc558a533ef62363a8",
                    counterpartyNodeId: "0204ad94e0ac2e1bba3f03edfbc95aa5a7d3114a12a22610a7adba123f1f01d437",
                    fundingTxo: nil,
                    shortChannelId: nil,
                    outboundScidAlias: nil,
                    inboundScidAlias: nil,
                    channelValueSatoshis: UInt64(1),
                    unspendablePunishmentReserve: nil,
                    userChannelId: "2ff575465c3aed395d5eaafbf0cd69bb1397b52dd34adfcc558a533ef62363a8",
                    balanceMsat: UInt64(2),
                    outboundCapacityMsat: UInt64(3),
                    inboundCapacityMsat: UInt64(4),
                    confirmationsRequired: nil,
                    confirmations: nil,
                    isOutbound: true,
                    isChannelReady: true,
                    isUsable: false,
                    isPublic: true,
                    cltvExpiryDelta: nil
                )
            ),
            refreshFlag: .constant(false)
        )
        .environment(\.colorScheme, .dark)
        
    }
    
}
