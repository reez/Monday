//
//  ChannelView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/21/23.
//

import SwiftUI
import LightningDevKitNode
import WalletUI

class ChannelViewModel: ObservableObject {
    @Published var pubKey: String = ""
    @Published var hostname: String = ""
    @Published var port: String = ""
    @Published var sats: String = ""
    
//    func createNodePubkeyAddress() -> String {
//        let nodeAddressAndPort = "\(pubKey)@\(hostname):\(port)"
//        return nodeAddressAndPort
//    }
//
//    func openChannel(nodePubkeyAndAddress: String, channelAmountSats: UInt64) {
//        LightningNodeService.shared.openChannel(
//            nodePubkeyAndAddress: nodePubkeyAndAddress,
//            channelAmountSats: channelAmountSats
//        )
//    }
    
    func openChannel(nodeId: PublicKey, address: SocketAddr, channelAmountSats: UInt64) {
        LightningNodeService.shared.openChannel(
            nodeId: nodeId,
            address: address,
            channelAmountSats: channelAmountSats
        )
    }
    
}
struct ChannelView: View {
    @ObservedObject var viewModel: ChannelViewModel
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: UIColor.systemBackground)
                
                VStack {
                    
                    VStack(alignment: .leading) {
                        Text("Pubkey")
                        TextField("03a5b467d7f...4c2b099b8250c", text: $viewModel.pubKey)
                            .frame(height: 48)
                            .truncationMode(.middle)
                            .padding(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18))
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(lineWidth: 1.0)
                                    .foregroundColor(.secondary)
                            )
                    }
                    .padding()
                    
                    VStack(alignment: .leading) {
                        Text("Hostname")
                        TextField("127.0.0.1", text: $viewModel.hostname)
                            .frame(height: 48)
                            .padding(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18))
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(lineWidth: 1.0)
                                    .foregroundColor(.secondary)
                            )
                    }
                    .padding()
                    
                    VStack(alignment: .leading) {
                        Text("Port")
                        TextField("9735", text: $viewModel.port)
                            .frame(height: 48)
                            .padding(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18))
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(lineWidth: 1.0)
                                    .foregroundColor(.secondary)
                            )
                    }
                    .padding()
                    
                    VStack(alignment: .leading) {
                        Text("Sats")
                        TextField("6102", text: $viewModel.sats)
                            .frame(height: 48)
                            .padding(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18))
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(lineWidth: 1.0)
                                    .foregroundColor(.secondary)
                            )
                    }
                    .padding()
                    
                    Button {
//                        let nodePubkeyAndAddress = viewModel.createNodePubkeyAddress()
//                        let channelAmountSats = UInt64(viewModel.sats) ?? UInt64(100)
//                        viewModel.openChannel(
//                            nodePubkeyAndAddress: nodePubkeyAndAddress,
//                            channelAmountSats: channelAmountSats
//                        )
                        
                        let nodeId = PublicKey.init()
                        let address = SocketAddr.init()
                        let channelAmountSats = UInt64(viewModel.sats) ?? UInt64(100)
                        viewModel.openChannel(
                            nodeId: nodeId,
                            address: address,
                            channelAmountSats: channelAmountSats
                        )
                    } label: {
                        Text("Open Channel")
                    }
                    .buttonStyle(BitcoinOutlined())
                    .padding()
                    
                }
                .padding()
                .padding(.top)
                .navigationTitle("Channel")
                
            }
            .ignoresSafeArea()
            
        }
        
    }
}

struct ChannelView_Previews: PreviewProvider {
    static var previews: some View {
        ChannelView(viewModel: .init())
        ChannelView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
