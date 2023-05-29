//
//  ChannelsListView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/1/23.
//

import SwiftUI
import LightningDevKitNode
import WalletUI

struct ChannelsListView: View {
    @ObservedObject var viewModel: ChannelsListViewModel
    @State private var isSendPresented = false
    @State private var isReceivePresented = false
    @State private var isViewPeersPresented = false
    @State private var isAddChannelPresented = false
    @State private var refreshFlag = false

    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: UIColor.systemBackground)
                
                VStack {
                    
                    Button {
                        isViewPeersPresented = true
                    } label: {
                        Text("View Peers")
                    }
                    .buttonStyle(BitcoinOutlined(tintColor: viewModel.networkColor))
                    .padding()
                    
                    Button {
                        isAddChannelPresented = true
                    } label: {
                        Text("Add Channel")
                    }
                    .buttonStyle(BitcoinOutlined(tintColor: viewModel.networkColor))
                    .padding()
                    
                    if viewModel.channels.isEmpty {
                        
                        Text("No Channels")
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                        
                    } else {
                        
                        List {
                            
                            ForEach(viewModel.channels, id: \.self) { channel in
                                
                                NavigationLink {
                                    ChannelCloseView(
                                        viewModel: .init(channel: channel),
                                        refreshFlag: $refreshFlag
                                    )
                                } label: {
                                    
                                    VStack {
                                        
                                        HStack(alignment: .center) {
                                            
                                            ZStack {
                                                
                                                Circle()
                                                    .frame(width: 50.0, height: 50.0)
                                                    .foregroundColor(viewModel.networkColor)
                                                
                                                Image(systemName: "person.line.dotted.person")
                                                    .font(.subheadline)
                                                    .foregroundColor(Color(uiColor: .systemBackground))
                                                    .bold()
                                                
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 5.0) {
                                                
                                                Text("\(channel.channelValueSatoshis) sats ")
                                                    .font(.caption)
                                                    .bold()
                                                
                                                Text(channel.counterpartyNodeId)
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
                                .listRowBackground(Color.clear)
                                
                            }
                            
                        }
                        .listStyle(.plain)
                        
                    }
                    
                    Spacer()
                    
                    HStack {
                        
                        Button {
                            isSendPresented = true
                        } label: {
                            HStack {
                                Image(systemName: "arrow.up")
                                Text("Send")
                            }
                        }
                        .tint(viewModel.networkColor)
                        .buttonStyle(BitcoinOutlined(width: 125, tintColor: viewModel.networkColor))
                        
                        Spacer()
                        
                        Button {
                            isReceivePresented = true
                        } label: {
                            HStack {
                                Image(systemName: "arrow.down")
                                Text("Receive")
                            }
                        }
                        .tint(viewModel.networkColor)
                        .buttonStyle(BitcoinOutlined(width: 125, tintColor: viewModel.networkColor))
                        
                    }
                    .padding()
                    
                }
                .padding()
                .padding(.top)
                .navigationTitle("\(viewModel.channels.count) Channels")
                .onAppear {
                    viewModel.listChannels()
                    viewModel.getColor()
                    if refreshFlag {
                        viewModel.listChannels()
                        refreshFlag = false // Reset the flag
                    }
                }
                .sheet(isPresented: $isSendPresented, onDismiss: {
                    viewModel.listChannels()
                }) {
                    SendView(viewModel: .init())
                }
                .sheet(isPresented: $isReceivePresented, onDismiss: {
                    viewModel.listChannels()
                }) {
                    ReceiveView(viewModel: .init())
                }
                .sheet(isPresented: $isViewPeersPresented, onDismiss: {
                    viewModel.listChannels()
                }) {
                    PeersListView(viewModel: .init())
                }
                .sheet(isPresented: $isAddChannelPresented, onDismiss: {
                    viewModel.listChannels()
                }) {
                    ChannelAddView(viewModel: .init())
                }
                
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
