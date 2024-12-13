//
//  ChannelsListView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/1/23.
//

import BitcoinUI
import SwiftUI

struct ChannelsListView: View {
    @State private var refreshFlag = false
    let viewModel: ChannelsListViewModel

    var body: some View {
        ZStack {

            VStack {
                if viewModel.channels.isEmpty {
                    Text("No Channels")
                } else {
                    List {
                        ForEach(
                            viewModel.channels.sorted(by: {
                                $0.channelValueSats > $1.channelValueSats
                            }),
                            id: \.self
                        ) { channel in
                            NavigationLink {
                                ChannelDetailView(
                                    viewModel: .init(channel: channel),
                                    refreshFlag: $refreshFlag
                                )
                            } label: {
                                HStack(alignment: .center, spacing: 15) {
                                    ZStack {
                                        Circle()
                                            .stroke(lineWidth: 2)
                                                .frame(width: 40, height: 40)
                                        Image(systemName: "fibrechannel")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 16, height: 16)
                                    }
                                    HStack(alignment: .center) {

                                        VStack(alignment: .leading) {
                                            Text("\(channel.channelValueSats) sats ")
                                                .fontWeight(.medium)
                                                .truncationMode(.tail)
                                                .lineLimit(1)
                                            HStack {
                                                if let alias = viewModel.aliases[
                                                    channel.counterpartyNodeId
                                                ] {
                                                    Text(alias)
                                                } else {
                                                    Text(channel.counterpartyNodeId)
                                                        .truncationMode(.middle)
                                                        .lineLimit(1)
                                                }
                                            }.font(.subheadline)
                                                //.foregroundColor(.secondary)
                                            
                                            HStack {
                                                Text("Send \(channel.outboundCapacityMsat/1000) sats ")
                                                Spacer()
                                                Text(
                                                    "Receive \(channel.inboundCapacityMsat/1000) sats "
                                                )
                                            }.font(.caption)
                                                .foregroundColor(.secondary)

                                        }

                                        /*
                                        Spacer()

                                        VStack(alignment: .leading) {
                                            Text("Send \(channel.outboundCapacityMsat/1000) sats ")
                                            //Spacer()
                                            Text(
                                                "Receive \(channel.inboundCapacityMsat/1000) sats "
                                            )
                                        }.font(.caption)
                                            .foregroundColor(.secondary)
                                         */
                                    }
                                    Spacer()
                                }.padding(.top, 5)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .refreshable {
                        await viewModel.listChannels()
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.listChannels()
                    viewModel.getColor()
                }
            }
        }.dynamicTypeSize(...DynamicTypeSize.accessibility1)  // Sets max dynamic size for all Text
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .navigationTitle("Channels")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ChannelAddView(viewModel: .init())) {
                        Text("Add")
                    }
                }
            }

    }
}

#if DEBUG
    #Preview {
        ChannelsListView(viewModel: .init(nodeInfoClient: .mock))
    }
#endif
