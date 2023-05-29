//
//  DisconnectView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/2/23.
//

import SwiftUI
import LightningDevKitNode
import WalletUI

class DisconnectViewModel: ObservableObject {
    @Published var errorMessage: MondayNodeError?
    @Published var networkColor = Color.gray
    @Published var nodeId: PublicKey
    
    init(nodeId: PublicKey) {
        self.nodeId = nodeId
    }
    
    func disconnect() {
        do {
            try LightningNodeService.shared.disconnect(nodeId: self.nodeId)
            errorMessage = nil
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.errorMessage = .init(title: errorString.title, detail: errorString.detail)
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = .init(title: "Unexpected error", detail: error.localizedDescription)
            }
        }
    }
    
    func getColor() {
        let color = LightningNodeService.shared.networkColor
        DispatchQueue.main.async {
            self.networkColor = color
        }
    }
    
}
struct DisconnectView: View {
    @ObservedObject var viewModel: DisconnectViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingErrorAlert = false
    
    var body: some View {
        
        ZStack {
            Color(uiColor: UIColor.systemBackground)
            
            VStack {
                
                HStack {
                    
                    Text("Node ID:")
                    
                    Text(viewModel.nodeId.description)
                        .truncationMode(.middle)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                    
                }
                .font(.system(.caption, design: .monospaced))
                .padding()
                
                Button("Disconnect Peer") {
                    
                    viewModel.disconnect()
                    if showingErrorAlert == false {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.presentationMode.wrappedValue.dismiss()
//                        }
                    }
                    
                    if showingErrorAlert == true {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.presentationMode.wrappedValue.dismiss()
//                        }
                    }
                    
                }
                .buttonStyle(BitcoinOutlined(tintColor: viewModel.networkColor))
                
            }
            .padding()
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
                viewModel.getColor()
            }
            
        }
        .ignoresSafeArea()
        
    }
    
}

struct DisconnectView_Previews: PreviewProvider {
    static var previews: some View {
        DisconnectView(viewModel: .init(nodeId: "03e39c737a691931dac0f9f9ee803f2ab08f7fd3bbb25ec08d9b8fdb8f51d3a8db"))
        DisconnectView(viewModel: .init(nodeId: "03e39c737a691931dac0f9f9ee803f2ab08f7fd3bbb25ec08d9b8fdb8f51d3a8db"))
            .environment(\.colorScheme, .dark)
    }
}
