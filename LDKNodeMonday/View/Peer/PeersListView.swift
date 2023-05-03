//
//  PeersListView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/2/23.
//

import SwiftUI
import LightningDevKitNode
import WalletUI

class PeersListViewModel: ObservableObject {
    @Published var peers: [PeerDetails] = []
    
    func listPeers() {
        self.peers = LightningNodeService.shared.listPeers()
    }
    
}
struct PeersListView: View {
    @ObservedObject var viewModel: PeersListViewModel
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: UIColor.systemBackground)
                
                VStack {
                    
                    NavigationLink(destination: PeerView(viewModel: .init())) {
                        Text("Connect Peer")
                    }
                    .buttonStyle(BitcoinOutlined())
                    .padding()
                    
                    if viewModel.peers.isEmpty {
                        Text("No Peers")
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
//                                                    .foregroundColor(.orange)
                                                    .foregroundColor(LightningNodeService.shared.networkColor)

                                                Image(systemName: "person.line.dotted.person")
                                                    .font(.subheadline)
                                                    .foregroundColor(Color(uiColor: .systemBackground))
                                                    .bold()
                                                
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 5.0) {
                                                
                                                HStack {
                                                    
                                                    peer.isConnected ?
                                                    HStack(spacing: 2) {
                                                        Image(systemName: "checkmark")
                                                        Text("Connected")
                                                    }
                                                    .font(.caption)
                                                    .bold()
                                                    :
                                                    HStack {
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
                                
                            }
                            
                        }
                        .listStyle(.plain)
                        
                    }
                    
                }
                .padding()
                .padding(.top)
                .navigationTitle("\(viewModel.peers.count) Peers")
                .onAppear {
                    viewModel.listPeers()
                    print("peers count: \(viewModel.peers.count)")
                }
                
            }
            .ignoresSafeArea()
            
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
