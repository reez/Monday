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
    
    @Published var nodeID: String = "..."
    
    func getNodeID() {
        let nodeID = LightningNodeService.shared.getNodeId()
        self.nodeID = nodeID
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
                        }
                    }
                    .padding(.horizontal)
                    
                }
                .padding()
                .onAppear {
                    Task {
                        viewModel.getNodeID()
                    }
                }
                .navigationTitle("Node ID")
                
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
