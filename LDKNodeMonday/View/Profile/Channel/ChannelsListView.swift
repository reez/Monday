//
//  ChannelsListView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/1/23.
//

import BitcoinUI
import SwiftUI

struct ChannelsRefactorView: View {
    @State private var refreshFlag = false
    let viewModel: ChannelsListViewModel

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)

            VStack {
                if viewModel.channels.isEmpty {
                    Text("No Channels")
                        .font(.system(.caption, design: .monospaced))
                        .padding()
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
                                VStack {
                                    HStack(alignment: .center, spacing: 15) {
                                        ZStack {
                                            Circle()
                                                .frame(width: 50.0, height: 50.0)
                                                .foregroundColor(viewModel.networkColor)
                                            Image(systemName: "person.line.dotted.person")
                                                .font(.subheadline)
                                                .foregroundColor(
                                                    Color(uiColor: .systemBackground)
                                                )
                                                .bold()
                                        }
                                        VStack(alignment: .leading, spacing: 5.0) {
                                            Text("\(channel.channelValueSats) sats ")
                                                .font(.caption)
                                                .bold()
                                            if let alias = viewModel.aliases[
                                                channel.counterpartyNodeId
                                            ] {
                                                Text(alias)
                                                    .font(.caption)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.secondary)
                                            }
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
        }
        .navigationTitle(
            "Channels"
        )

    }
}

struct ChannelsRefactorView_Previews: PreviewProvider {
    static var previews: some View {
        ChannelsRefactorView(viewModel: .init(nodeInfoClient: .mock))
        ChannelsRefactorView(viewModel: .init(nodeInfoClient: .mock))
            .environment(\.sizeCategory, .accessibilityLarge)
        ChannelsRefactorView(viewModel: .init(nodeInfoClient: .mock))
            .environment(\.colorScheme, .dark)
    }
}
