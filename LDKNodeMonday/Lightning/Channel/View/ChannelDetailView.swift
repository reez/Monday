//
//  ChannelCloseView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/2/23.
//

import SwiftUI
import WalletUI
import LightningDevKitNode

struct ChannelDetailView: View {
    @ObservedObject var viewModel: ChannelDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingChannelDetailViewErrorAlert = false
    @Binding var refreshFlag: Bool
    
    var body: some View {
        
        ZStack {
            Color(uiColor: UIColor.systemBackground)
            
            VStack {
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Channel ID:")
                        Spacer()
                        Text(viewModel.channel.channelId.description)
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Counterparty Node ID:")
                        Spacer()
                        Text(viewModel.channel.counterpartyNodeId.description)
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Channel Value Satoshis:")
                        Spacer()
                        Text(viewModel.channel.channelValueSatoshis.description)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Balance (msat):")
                        Spacer()
                        Text(viewModel.channel.balanceMsat.description)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Outbound Capacity (msat):")
                        Spacer()
                        Text(viewModel.channel.outboundCapacityMsat.description)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Inbound Capacity (msat):")
                        Spacer()
                        Text(viewModel.channel.inboundCapacityMsat.description)
                            .foregroundColor(.secondary)
                    }
                    if let confirm = viewModel.channel.confirmations {
                        HStack {
                            Text("Confirmations:")
                            Spacer()
                            Text(confirm.description)
                                .foregroundColor(.secondary)
                        }
                    }
                    HStack {
                        Text("Is Channel Ready:")
                        Spacer()
                        Text(viewModel.channel.isChannelReady.description)
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Is Usable:")
                        Spacer()
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
        
        let channel = ChannelDetails.init(
            channelId: ChannelId(stringLiteral: "channelID"),
            counterpartyNodeId: PublicKey(stringLiteral: "counterpartyNodeId"),
            fundingTxo: nil,
            channelValueSatoshis: UInt64(1000),
            unspendablePunishmentReserve: nil,
            userChannelId: UserChannelId(stringLiteral: "userChannelId"),
            feerateSatPer1000Weight: UInt32(20),
            balanceMsat: UInt64(2000),
            outboundCapacityMsat: UInt64(500),
            inboundCapacityMsat: UInt64(400),
            confirmationsRequired: nil,
            confirmations: nil,
            isOutbound: false,
            isChannelReady: true,
            isUsable: true,
            isPublic: true,
            cltvExpiryDelta: nil
        )
        ChannelDetailView(viewModel: .init(channel: channel), refreshFlag: .constant(false))
        ChannelDetailView(viewModel: .init(channel: channel), refreshFlag: .constant(false))
                .environment(\.colorScheme, .dark)
        
    }
    
}
