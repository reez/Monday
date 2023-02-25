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
    @Published var pubKey: String = "0f211ed889948482f181b7f86360005b7cfb99c99b386a0ee7508290cb34e0bba7"
    @Published var hostname: String = "127.0.0.1"
    @Published var port: String = "9735"
    @Published var sats: String = "100"
    
    func createNodePubkeyAddress() -> String {
        let nodeAddressAndPort = "\(pubKey)@\(hostname):\(port)"
        return nodeAddressAndPort
    }
    
    func openChannel(nodePubkeyAndAddress: String, channelAmountSats: UInt64) {
        LightningNodeService.shared.openChannel(
            nodePubkeyAndAddress: nodePubkeyAndAddress,
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
                        TextField(
                            "Pubkey",
                            text: $viewModel.pubKey
                        )
                        .textFieldStyle(.roundedBorder)
                        .truncationMode(.middle)
                        .font(.caption)
                    }
                    .padding()

                    VStack(alignment: .leading) {
                        Text("Hostname")
                        TextField(
                            "Hostname",
                            text: $viewModel.hostname
                        )
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                    }
                    .padding()

                    VStack(alignment: .leading) {
                        Text("Port")
                        TextField(
                            "Port",
                            text: $viewModel.port
                        )
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .font(.caption)
                    }
                    .padding()

                    VStack(alignment: .leading) {
                        Text("Sats")
                        TextField(
                            "Amount Sats",
                            text: $viewModel.sats
                        )
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .font(.caption)
                    }
                    .padding()

                    Button {
                        let nodePubkeyAndAddress = viewModel.createNodePubkeyAddress()
                        let channelAmountSats = UInt64(viewModel.sats) ?? UInt64(100)
                        viewModel.openChannel(
                            nodePubkeyAndAddress: nodePubkeyAndAddress,
                            channelAmountSats: channelAmountSats
                        )
                    } label: {
                        Text("Open Channel")
                    }
                    .buttonStyle(BitcoinOutlined())
                    .padding()
                    
                }
                .padding()
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
