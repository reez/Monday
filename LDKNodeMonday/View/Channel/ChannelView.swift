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
    @Published var nodeId: PublicKey = ""
    @Published var address: SocketAddr = ""
    @Published var channelAmountSats: String = ""
    @Published var networkColor = Color.gray

    func openChannel(nodeId: PublicKey, address: SocketAddr, channelAmountSats: UInt64, pushToCounterpartyMsat: UInt64?) {
        LightningNodeService.shared.connectOpenChannel(
            nodeId: nodeId,
            address: address,
            channelAmountSats: channelAmountSats,
            pushToCounterpartyMsat: pushToCounterpartyMsat
        )
    }
    
    func getColor() {
        let color = LightningNodeService.shared.networkColor
        self.networkColor = color
    }
    
}

struct ChannelView: View {
    @ObservedObject var viewModel: ChannelViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        ZStack {
            Color(uiColor: UIColor.systemBackground)
            
            VStack {
                
                VStack(alignment: .leading) {
                    
                    Text("Node ID")
                        .bold()
                    
                    TextField("03a5b467d7f...4c2b099b8250c", text: $viewModel.nodeId)
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
                    
                    Text("Address")
                        .bold()
                    
                    TextField("172.18.0.2:9735", text: $viewModel.address)
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
                        .bold()
                    
                    TextField("125000", text: $viewModel.channelAmountSats)
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
                    let channelAmountSats = UInt64(viewModel.channelAmountSats) ?? UInt64(101010)
                    viewModel.openChannel(
                        nodeId: viewModel.nodeId,
                        address: viewModel.address,
                        channelAmountSats: channelAmountSats,
                        pushToCounterpartyMsat: nil // TODO: actually make this inputtable
                    )
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Text("Open Channel")
                }
                .buttonStyle(BitcoinOutlined(tintColor: viewModel.networkColor))
                .padding()
                
                
            }
            .padding()
            .navigationBarTitle("Channel")
            .onAppear {
                viewModel.getColor()
            }
            
        }
        .ignoresSafeArea()
        
    }
    
}

struct ChannelView_Previews: PreviewProvider {
    static var previews: some View {
        ChannelView(viewModel: .init())
        ChannelView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
