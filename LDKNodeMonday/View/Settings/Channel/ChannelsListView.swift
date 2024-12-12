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
                                            .frame(width: 40.0, height: 40.0)
                                            .foregroundColor(.accentColor)
                                        Image(systemName: "fibrechannel")
                                            .font(.subheadline).dynamicTypeSize(...DynamicTypeSize.large)
                                            .foregroundColor(Color(uiColor: .systemBackground))
                                            .bold()
                                    }
                                    HStack(alignment: .center) {

                                        VStack(alignment: .leading) {
                                            Text("\(channel.channelValueSats) sats ")
                                                .font(.subheadline.weight(.medium))
                                                //.frame(width: 100)
                                                .truncationMode(.tail)
                                                .lineLimit(1)
                                            HStack {
                                                if let alias = viewModel.aliases[
                                                    channel.counterpartyNodeId
                                                ] {
                                                    Text(alias)
                                                } else {
                                                    Text(channel.counterpartyNodeId)
                                                        //.frame(width: 100)
                                                        .truncationMode(.middle)
                                                        .lineLimit(1)
                                                }
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
                                }
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
                        .fontWeight(.medium)
                        .padding()
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
