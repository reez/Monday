//
//  NodeIDView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/21/23.
//

import SwiftUI
import LightningDevKitNode
import WalletUI

class NodeIDViewModel: ObservableObject {
    @Published var nodeID: String = ""
    @Published var networkColor = Color.gray
    
    func getNodeID() {
        let nodeID = LightningNodeService.shared.nodeId()
        self.nodeID = nodeID
    }
    
    func stop() {
        LightningNodeService.shared.stop()
    }
    
    func getColor() {
        let color = LightningNodeService.shared.networkColor
        self.networkColor = color
    }
    
}

struct NodeIDView: View {
    @ObservedObject var viewModel: NodeIDViewModel
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: UIColor.systemBackground)
                
                VStack(spacing: 20.0) {
                    
                    Image(systemName: "person.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(viewModel.networkColor)
                    
                    Text("Node ID")
                        .textStyle(BitcoinTitle5())
                    
                    HStack(alignment: .bottom) {
                        
                        Text(viewModel.nodeID)
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                        
                        Button {
                            UIPasteboard.general.string = viewModel.nodeID
                        } label: {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                    .font(.subheadline)
                            }
                            .bold()
                            .foregroundColor(viewModel.networkColor)
                            
                        }
                        
                    }
                    .padding(.horizontal)
                    
                    Button("Stop Node") {
                        viewModel.stop()
                    }
                    .buttonStyle(BitcoinOutlined(tintColor: viewModel.networkColor))
                    .padding(.top, 100.0)
                    
                    NavigationLink {
                        LogView()
                    } label: {
                        Text("See Log File")
                    }
                    .buttonStyle(BitcoinOutlined(tintColor: viewModel.networkColor))


                    
                }
                .padding()
                .navigationTitle("Node ID")
                .onAppear {
                    Task {
                        viewModel.getNodeID()
                        viewModel.getColor()
                    }
                }
                
            }
            .ignoresSafeArea()
            
        }
        
    }
    
}

struct NodeIDView_Previews: PreviewProvider {
    static var previews: some View {
        NodeIDView(viewModel: .init())
        NodeIDView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
