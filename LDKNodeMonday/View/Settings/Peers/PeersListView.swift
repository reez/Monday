//
//  PeersListView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/2/23.
//

import BitcoinUI
import SwiftUI

struct PeersListView: View {
    @ObservedObject var viewModel: PeersListViewModel

    var body: some View {

        VStack {

            if viewModel.peers.isEmpty {
                Text("No Peers")
            } else {
                List {
                    ForEach(viewModel.peers, id: \.self) { peer in
                        NavigationLink {
                            DisconnectView(viewModel: .init(nodeId: peer.nodeId))
                        } label: {
                            VStack {
                                HStack(alignment: .center, spacing: 15) {
                                    ZStack {
                                        Circle()
                                            .frame(width: 40.0, height: 40.0)
                                            .foregroundColor(.accentColor)
                                        Image(systemName: "person.line.dotted.person")
                                            .font(.subheadline)
                                            .foregroundColor(Color(uiColor: .systemBackground))
                                            .bold()
                                    }
                                    VStack(alignment: .leading, spacing: 5.0) {
                                        Text("\(peer.nodeId) ")
                                            .frame(width: 150)
                                            .truncationMode(.middle)
                                            .lineLimit(1)
                                            .font(.subheadline.weight(.medium))
                                        peer.isConnected
                                            ? HStack(alignment: .firstTextBaseline, spacing: 2) {
                                                Text("Connected")
                                                Image(systemName: "checkmark")
                                            }.font(.caption)
                                                .foregroundColor(.secondary)
                                            : HStack {
                                                Text("Not Connected")
                                                Image(systemName: "xmark")
                                            }.font(.caption)
                                                .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
            }

        }.listStyle(.plain)
            .scrollContentBackground(.hidden)
            .navigationTitle("Peers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: PeerView(viewModel: .init())) {
                        Text("Add")
                            .fontWeight(.medium)
                            .padding()
                    }
                }
            }
            .onAppear {
                Task {
                    viewModel.listPeers()
                    viewModel.getColor()
                }
            }
    }

}

#if DEBUG
    #Preview {
        PeersListView(viewModel: .init())
    }
#endif
