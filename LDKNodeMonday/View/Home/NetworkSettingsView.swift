//
//  NetworkSettingsView.swift
//  LDKNodeMonday
//
//  Created by Daniel Nordh on 03/12/2024.
//

import SwiftUI
import LDKNode

struct NetworkSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var viewModel: OnboardingViewModel
    
    var body: some View {
        
        NavigationView {
            Form {
                Section() {
                    Picker(
                        "Network",
                        selection: $viewModel.selectedNetwork
                    ) {
                        Text("Signet").tag(Network.signet)
                        Text("Testnet").tag(Network.testnet)
                    } 
                    .pickerStyle(.navigationLink)
                    .accessibilityLabel("Select bitcoin network")
                    .scrollContentBackground(.hidden)
                    
                    Picker(
                        "Server",
                        selection: $viewModel.selectedEsploraServer
                    ) {
                        ForEach(viewModel.availableEsploraServers, id: \.self) { esploraServer in
                            Text(esploraServer.name).tag(esploraServer)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .accessibilityLabel("Select esplora server")
                    .scrollContentBackground(.hidden)
                } footer: {
                    Text("Set your desired network and connection server.\nIf in doubt, use the default settings.")
                }
            }
            .navigationTitle("Network settings")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    })
                }
            }
        }
        .padding(.bottom, 20)
        .accentColor(.accentColor)
        .scrollContentBackground(.hidden)
    }
}

#if DEBUG
#Preview {
    NetworkSettingsView(viewModel: .init())
}
#endif
