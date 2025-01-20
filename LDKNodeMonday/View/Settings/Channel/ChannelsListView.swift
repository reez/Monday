//
//  ChannelsListView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/1/23.
//

import BitcoinUI
import LDKNode
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
                                    viewModel: .init(
                                        channel: channel,
                                        lightningClient: viewModel.lightningClient
                                    ),
                                    refreshFlag: $refreshFlag
                                )
                            } label: {
                                ChannelRow(
                                    channel: channel,
                                    alias: viewModel.aliases[channel.counterpartyNodeId]
                                )
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
                }
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .navigationTitle("Channels")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(
                    destination: ChannelAddView(
                        viewModel: .init(lightningClient: viewModel.lightningClient)
                    )
                ) {
                    Label("Add", systemImage: "plus")
                        .labelStyle(.titleAndIcon)
                }
            }
        }
    }
}

struct ChannelRow: View {
    let channel: ChannelDetails
    let alias: String?

    var body: some View {
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

            VStack(alignment: .leading) {
                Text("\(channel.channelValueSats) sats")
                    .fontWeight(.medium)
                    .truncationMode(.tail)
                    .lineLimit(1)

                HStack {
                    if let alias = alias {
                        Text(alias)
                    } else {
                        Text(channel.counterpartyNodeId)
                            .truncationMode(.middle)
                            .lineLimit(1)
                    }
                }.font(.subheadline)

                HStack {
                    Text("Send \(channel.outboundCapacityMsat/1000) sats")
                    Spacer()
                    Text("Receive \(channel.inboundCapacityMsat/1000) sats")
                }.font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }.padding(.top, 5)
    }
}

#if DEBUG
    #Preview {
        ChannelsListView(viewModel: .init(nodeInfoClient: .mock, lightningClient: .mock))
    }
#endif
