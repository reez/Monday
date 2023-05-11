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
    @Published var errorMessage: NodeErrorMessage?//String?
    
    func getNodeID() {
        let nodeID = LightningNodeService.shared.nodeId()
        self.nodeID = nodeID
    }
    
    //    func stop() {
    //        LightningNodeService.shared.stop()
    //    }
    
    func stop() {
        do {
            try LightningNodeService.shared.stop()
        } catch let error as NodeError {
            // handle NodeError
            let errorString = handleNodeError(error)
            //            errorMessage = .init(title: errorString.title, detail: errorString.detail)//"Title: \(errorString.title) ... Detail: (\(errorString.detail))"//"Node error: \(error.localizedDescription)"
            DispatchQueue.main.async {
                self.errorMessage = .init(title: errorString.title, detail: errorString.detail)
            }
            print("Title: \(errorString.title) ... Detail: \(errorString.detail))")
        } catch {
            // handle other errors
            print("LDKNodeMonday /// error getting connect: \(error.localizedDescription)")
            //            errorMessage = .init(title: "Unexpected error", detail: error.localizedDescription)//"Unexpected error: \(error.localizedDescription)"
            DispatchQueue.main.async {
                self.errorMessage = .init(title: "Unexpected error", detail: error.localizedDescription)
            }
        }
    }
    
    func getColor() {
        let color = LightningNodeService.shared.networkColor
        self.networkColor = color
    }
    
}

struct NodeIDView: View {
    @ObservedObject var viewModel: NodeIDViewModel
    @State private var showingErrorAlert = false
    @State private var isCopied = false
    @State private var showCheckmark = false

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
                        
//                        Button {
//                            UIPasteboard.general.string = viewModel.nodeID
//                            print("copied node id: \(viewModel.nodeID)")
//                        } label: {
//                            HStack {
//                                Image(systemName: "doc.on.doc")
//                                    .font(.subheadline)
//                            }
//                            .bold()
//                            .foregroundColor(viewModel.networkColor)
//                        }
                        
                        Button(action: {
                            UIPasteboard.general.string = viewModel.nodeID
                            print("copied node id: \(viewModel.nodeID)")

                            // Update button state
                            isCopied = true
                            showCheckmark = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                // Revert button state after 2 seconds
                                isCopied = false
                                showCheckmark = false
                            }
                        }) {
                            HStack {
                                Image(systemName: showCheckmark ? "checkmark" : "doc.on.doc")
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
