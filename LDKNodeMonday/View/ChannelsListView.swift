//
//  ChannelsListView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/1/23.
//

import SwiftUI
import LightningDevKitNode
import WalletUI

class ChannelsListViewModel: ObservableObject {
//    @Published var nodeId: PublicKey = ""
//    @Published var address: SocketAddr = ""
//    @Published var channelAmountSats: String = ""
    @Published var channels: [ChannelDetails] = []
//
//    func openChannel(nodeId: PublicKey, address: SocketAddr, channelAmountSats: UInt64) {
//        LightningNodeService.shared.openChannel(
//            nodeId: nodeId,
//            address: address,
//            channelAmountSats: channelAmountSats
//        )
//    }
    
    func listChannels() {
        self.channels = LightningNodeService.shared.listChannels()
    }
    
}
struct ChannelsListView: View {
    @ObservedObject var viewModel: ChannelsListViewModel

    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: UIColor.systemBackground)
                
                VStack {
                    
                        NavigationLink(destination: ChannelView(viewModel: .init())) {
                           Text("Add Channel")
                        }
                        .buttonStyle(BitcoinOutlined())
                        .padding()
                    
                    if viewModel.channels.isEmpty {
                        Text("No Channels")
                    } else {
                        
                        List {
                            
                            ForEach(viewModel.channels, id: \.self) { channel in
                                
                                VStack {
                                    
                                    HStack(alignment: .center) {
                                        
                                        ZStack {
                                            Circle()
                                                .frame(width: 50.0, height: 50.0)
                                                .foregroundColor(.orange)
                                            Image(systemName: "person.line.dotted.person")
                                                .font(.subheadline)
                                                .foregroundColor(Color(uiColor: .systemBackground))
                                                .bold()
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 5.0) {
                                            Text("\(channel.channelValueSatoshis) sats ")
                                                .font(.caption)
                                                .bold()
                                         
                                            Text(channel.counterparty)
                                                .font(.caption)
                                                .truncationMode(.middle)
                                                .lineLimit(1)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()

                                    }
                                    .padding()

                                }

                            }

                        }
                        .listStyle(.plain)

                    }
                    
                }
                .padding()
                .padding(.top)
                .navigationTitle("\(viewModel.channels.count) Channels")
                .onAppear { viewModel.listChannels() }
                
            }
            
        }
      
    }
    
}

struct ChannelsListView_Previews: PreviewProvider {
    static var previews: some View {
        ChannelsListView(viewModel: .init())
        ChannelsListView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
