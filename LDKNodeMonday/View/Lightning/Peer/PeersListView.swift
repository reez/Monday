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
    @State private var isAddPeerPresented = false

    var body: some View {

        NavigationView {

            ZStack {
                Color(uiColor: UIColor.systemBackground)

                VStack {

                    Button {
                        isAddPeerPresented = true
                    } label: {
                        HStack(spacing: 1) {
                            Image(systemName: "plus")
                            Text("Add Peer")
                        }
                        .foregroundColor(Color(uiColor: UIColor.systemBackground))
                        .bold()
                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.borderedProminent)
                    .tint(viewModel.networkColor)

                    if viewModel.peers.isEmpty {
                        Text("No Peers")
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                    } else {
                        List {
                            ForEach(viewModel.peers, id: \.self) { peer in
                                NavigationLink {
                                    DisconnectView(viewModel: .init(nodeId: peer.nodeId))
                                } label: {
                                    VStack {
                                        HStack(alignment: .center) {
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
                                                HStack {
                                                    peer.isConnected
                                                        ? HStack(spacing: 2) {
                                                            Image(systemName: "checkmark")
                                                            Text("Connected")
                                                        }
                                                        .font(.caption)
                                                        .bold()
                                                        : HStack {
                                                            Image(systemName: "xmark")
                                                            Text("Not Connected")
                                                        }
                                                        .font(.caption)
                                                        .bold()
                                                }
                                                Text("\(peer.nodeId) ")
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

                }
                .padding()
                .padding(.top)
                .onAppear {
                    Task {
                        viewModel.listPeers()
                        viewModel.getColor()
                    }
                }
                .sheet(
                    isPresented: $isAddPeerPresented,
                    onDismiss: {
                        Task {
                            viewModel.listPeers()
                        }
                    }
                ) {
                    PeerView(viewModel: .init())
                        .presentationDetents([.medium])
                }

            }

        }

    }

}

struct PeersListView_Previews: PreviewProvider {
    static var previews: some View {
        PeersListView(viewModel: .init())
        PeersListView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
