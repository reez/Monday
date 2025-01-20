//
//  PeersListView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/2/23.
//

import BitcoinUI
import LDKNode
import SwiftUI

struct PeersListView: View {
    @ObservedObject var viewModel: PeersListViewModel

    var body: some View {
        VStack {
            if viewModel.peers.isEmpty {
                Text("No Peers")
            } else {
                PeersList(peers: viewModel.peers, lightningClient: viewModel.lightningClient)
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .navigationTitle("Peers")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(
                    destination: PeerView(
                        viewModel: .init(lightningClient: viewModel.lightningClient)
                    )
                ) {
                    Label("Add", systemImage: "plus")
                        .labelStyle(.titleAndIcon)
                }
            }
        }
        .onAppear {
            viewModel.listPeers()
        }
    }
}

private struct PeersList: View {
    let peers: [PeerDetails]
    let lightningClient: LightningNodeClient

    var body: some View {
        List {
            ForEach(peers, id: \.self) { peer in
                NavigationLink {
                    PeerDetailsView(
                        viewModel: .init(
                            nodeId: peer.nodeId,
                            lightningClient: lightningClient
                        )
                    )
                } label: {
                    PeerRow(peer: peer)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }
}

private struct PeerRow: View {
    let peer: PeerDetails

    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 15) {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 2)
                        .frame(width: 40, height: 40)
                    Image(systemName: "person.line.dotted.person")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }
                VStack(alignment: .leading, spacing: 5.0) {
                    Text("\(peer.nodeId) ")
                        .truncationMode(.middle)
                        .lineLimit(1)
                        .font(.subheadline.weight(.medium))
                    ConnectionStatus(isConnected: peer.isConnected)
                }
            }
        }
    }
}

private struct ConnectionStatus: View {
    let isConnected: Bool

    var body: some View {
        if isConnected {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("Connected")
                Image(systemName: "checkmark")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        } else {
            HStack {
                Text("Not Connected")
                Image(systemName: "xmark")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
}

#if DEBUG
    #Preview {
        PeersListView(viewModel: .init(lightningClient: .mock))
    }
#endif
