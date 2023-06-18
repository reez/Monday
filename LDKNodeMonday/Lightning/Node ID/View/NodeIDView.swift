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
    @State private var showingNodeIDErrorAlert = false
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: UIColor.systemBackground)
                
                VStack(spacing: 20.0) {
                    
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(viewModel.networkColor)
                    
                    HStack(alignment: .center) {
                        Text(viewModel.nodeID)
                            .frame(width: 200, height: 50)
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
                        Text("View Log File")
                            .bold()
                            .foregroundColor(Color(uiColor: UIColor.systemBackground))
                            .frame(maxWidth: .infinity)
                            .padding(.all, 8)
                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.borderedProminent)
                    .tint(viewModel.networkColor)
                    .padding(.horizontal, 30.0)

                    
                }
                .padding()
                .navigationTitle("Node ID")
                .alert(isPresented: $showingNodeIDErrorAlert) {
                    Alert(
                        title: Text(viewModel.nodeIDError?.title ?? "Unknown"),
                        message: Text(viewModel.nodeIDError?.detail ?? ""),
                        dismissButton: .default(Text("OK")) {
                            viewModel.nodeIDError = nil
                        }
                    )
                }
                .onReceive(viewModel.$nodeIDError) { errorMessage in
                    if errorMessage != nil {
                        showingNodeIDErrorAlert = true
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
