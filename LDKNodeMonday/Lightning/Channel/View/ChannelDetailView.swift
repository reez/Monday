//
//  ChannelCloseView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/2/23.
//

import SwiftUI
import BitcoinUI
import LDKNode

struct ChannelDetailView: View {
    @ObservedObject var viewModel: ChannelDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingChannelDetailViewErrorAlert = false
    @Binding var refreshFlag: Bool
    
    var body: some View {
        
        ZStack {
            Color(uiColor: UIColor.systemBackground)
            
            VStack {
                
                Text(viewModel.channel.isOutbound ? "Outbound" : "Inbound").bold()
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Channel ID")
                        Spacer()
                        Text(viewModel.channel.channelId.description)
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Counterparty Node ID")
                            .lineLimit(1)
                        Spacer()
                        Text(viewModel.channel.counterpartyNodeId.description)
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Channel Value Satoshis")
                        Spacer()
                        Text(viewModel.channel.channelValueSats.formattedAmount())
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Balance Satoshis")
                        Spacer()
                        Text((viewModel.channel.balanceMsat / 1000).formattedAmount())
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Outbound Capacity Satoshis")
                        Spacer()
                        Text((viewModel.channel.outboundCapacityMsat / 1000).formattedAmount())
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Inbound Capacity Satoshis")
                        Spacer()
                        Text((viewModel.channel.inboundCapacityMsat / 1000).formattedAmount())
                            .foregroundColor(.secondary)
                    }
                    if let confirm = viewModel.channel.confirmations {
                        HStack {
                            Text("Confirmations")
                            Spacer()
                            Text(confirm.description)
                                .foregroundColor(.secondary)
                        }
                    }
                    HStack {
                        Text("Is Channel Ready")
                        Spacer()
                        Text(viewModel.channel.isChannelReady.description)
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Is Usable")
                        Spacer()
                        Text(viewModel.channel.isUsable.description)
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                }
                .font(.system(.caption2, design: .monospaced))
                .padding()
                
                Button {
                    viewModel.close()
                    refreshFlag = true
                    if showingChannelDetailViewErrorAlert == false {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                } label: {
                    Text("Close Channel")
                        .bold()
                        .foregroundColor(Color(uiColor: UIColor.systemBackground))
                        .frame(maxWidth: .infinity)
                        .padding(.all, 8)
                }
                .buttonBorderShape(.capsule)
                .buttonStyle(.borderedProminent)
                .tint(viewModel.networkColor)
                .padding(.horizontal)
                
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
            channelValueSats: UInt64(1000),
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
