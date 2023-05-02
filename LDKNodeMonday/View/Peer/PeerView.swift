//
//  PeerView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/2/23.
//

import SwiftUI
import LightningDevKitNode
import WalletUI

class PeerViewModel: ObservableObject {
    @Published var nodeId: PublicKey = ""
    @Published var address: SocketAddr = ""
//    @Published var channelAmountSats: String = ""
    
//    func openChannel(nodeId: PublicKey, address: SocketAddr, channelAmountSats: UInt64) {
//        LightningNodeService.shared.openChannel(
//            nodeId: nodeId,
//            address: address,
//            channelAmountSats: channelAmountSats
//        )
//    }
    
    func connect(
        nodeId: PublicKey,
        address: SocketAddr//,
//        permanently: Bool
    ){
        LightningNodeService.shared.connect(
            nodeId: nodeId,
            address: address,
            permanently: true//permanently
        )
    }
    
}

struct PeerView: View {
    @ObservedObject var viewModel: PeerViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        
//        NavigationView {
            
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
                    
                    Button {
                        viewModel.connect(
                            nodeId: viewModel.nodeId,
                            address: viewModel.address
                        )
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    } label: {
                        Text("Connect Peer")
                    }
                    .buttonStyle(BitcoinOutlined())
                    .padding()
                    
                }
                .padding()
//                .navigationBarTitle("Peer")

            }
//            .ignoresSafeArea()
            
//        }
        
    }
}

struct PeerView_Previews: PreviewProvider {
    static var previews: some View {
        PeerView(viewModel: .init())
        PeerView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
