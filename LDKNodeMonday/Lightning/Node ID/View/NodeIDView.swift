//
//  NodeIDView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/21/23.
//

import SwiftUI
import WalletUI

struct NodeIDView: View {
    @ObservedObject var viewModel: NodeIDViewModel
    @State private var isCopied = false
    @State private var showCheckmark = false
    @State private var showingErrorAlert = false
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: UIColor.systemBackground)
                
                VStack(spacing: 20.0) {
                    
                    Image(systemName: "person.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(viewModel.networkColor)
                    
                    HStack(alignment: .center) {
                        Text(viewModel.nodeID)
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                        Button {
                            UIPasteboard.general.string = viewModel.nodeID
                            isCopied = true
                            showCheckmark = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isCopied = false
                                showCheckmark = false
                            }
                        } label: {
                            HStack {
                                withAnimation {
                                    Image(systemName: showCheckmark ? "checkmark" : "doc.on.doc")
                                        .font(.subheadline)
                                }
                            }
                            .bold()
                            .foregroundColor(viewModel.networkColor)
                        }
                        
                    }
                    .padding(.horizontal)
                    
                    NavigationLink {
                        LogView()
                    } label: {
                        Text("See Log File")
                    }
                    .buttonStyle(BitcoinOutlined(tintColor: viewModel.networkColor))                    
                    
                }
                .padding()
                .navigationTitle("Node ID")
                .alert(isPresented: $showingErrorAlert) {
                    Alert(
                        title: Text(viewModel.errorMessage?.title ?? "Unknown"),
                        message: Text(viewModel.errorMessage?.detail ?? ""),
                        dismissButton: .default(Text("OK")) {
                            viewModel.errorMessage = nil
                        }
                    )
                }
                .onReceive(viewModel.$errorMessage) { errorMessage in
                    if errorMessage != nil {
                        showingErrorAlert = true
                    }
                }
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
