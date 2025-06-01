//
//  NetworkSettingsView.swift
//  LDKNodeMonday
//
//  Created by Daniel Nordh on 03/12/2024.
//

import LDKNode
import SwiftUI

struct NetworkSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var walletClient: WalletClient
    @State private var showRestartAlert = false
    @State private var tempNetwork: Network?
    @State private var tempServer: EsploraServer?

    // Create local state that tracks current values
    @State private var currentNetwork: Network
    @State private var currentServer: EsploraServer

    // Initialize the local state in the initializer
    init(walletClient: Binding<WalletClient>) {
        self._walletClient = walletClient
        self._currentNetwork = State(initialValue: walletClient.wrappedValue.network)
        self._currentServer = State(initialValue: walletClient.wrappedValue.server)
    }

    var body: some View {
        VStack {
            Form {
                Section {
                    Picker(
                        "Network",
                        selection: $currentNetwork
                    ) {
                        Text("Signet").tag(Network.signet)
                        Text("Testnet").tag(Network.testnet)
                    }
                    .pickerStyle(.navigationLink)
                    .accessibilityLabel("Select bitcoin network")
                    .onChange(of: currentNetwork) { oldValue, newValue in
                        guard let newServer = availableServers(network: newValue).first else {
                            fatalError("No servers available for \(newValue)")
                        }

                        currentServer = newServer

                        if walletClient.appState == .onboarding {
                            walletClient.network = newValue
                            walletClient.server = newServer
                        } else {
                            tempNetwork = newValue
                            tempServer = newServer
                            showRestartAlert = true
                        }
                    }

                    Picker(
                        "Server",
                        selection: $currentServer
                    ) {
                        ForEach(
                            availableServers(network: currentNetwork),
                            id: \.self
                        ) { esploraServer in
                            Text(esploraServer.name).tag(esploraServer)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .accessibilityLabel("Select esplora server")
                    .onChange(of: currentServer) { oldValue, newValue in
                        if walletClient.appState == .onboarding {
                            walletClient.server = newValue
                        } else {
                            tempServer = newValue
                            showRestartAlert = true
                        }
                    }
                } footer: {
                    Text(
                        "Set your desired network and connection server.\nIf in doubt, use the default settings."
                    )
                }
                .alert("Change and restart?", isPresented: $showRestartAlert) {
                    Button("Cancel", role: .cancel) {
                        // Reset local state to match wallet client on cancel
                        currentNetwork = walletClient.network

                        // Make sure we select a valid server for the current network
                        if availableServers(network: walletClient.network).contains(
                            walletClient.server
                        ) {
                            currentServer = walletClient.server
                        } else {
                            guard let server = availableServers(network: walletClient.network).first
                            else {
                                fatalError("No servers available for \(walletClient.network)")
                            }
                            currentServer = server
                        }

                        tempNetwork = nil
                        tempServer = nil
                    }
                    Button("Restart") {
                        Task {
                            await handleRestart()
                        }
                    }
                } message: {
                    Text("Changing network settings requires a restart of your node.")
                }
            }
            .navigationTitle("Network settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .tint(.accentColor)
    }

    private func handleRestart() async {
        if tempNetwork != nil || tempServer != nil {
            let newNetwork = tempNetwork ?? walletClient.network

            // If we only have tempServer but no tempNetwork, verify tempServer is valid for current network
            let newServer: EsploraServer
            if let server = tempServer {
                if availableServers(network: newNetwork).contains(server) {
                    newServer = server
                } else {
                    // If somehow the server is not valid for the network, use a default
                    guard let defaultServer = availableServers(network: newNetwork).first else {
                        fatalError("No servers available for \(newNetwork)")
                    }
                    newServer = defaultServer
                }
            } else {
                // No tempServer, use a default server for the new network
                guard let defaultServer = availableServers(network: newNetwork).first else {
                    fatalError("No servers available for \(newNetwork)")
                }
                newServer = defaultServer
            }

            do {
                try KeyClient.live.saveNetwork(newNetwork.description)
                try KeyClient.live.saveServerURL(newServer.url)
                await walletClient.restart(
                    newNetwork: newNetwork,
                    newServer: newServer
                )
            } catch let error {
                await MainActor.run {
                    debugPrint(error.localizedDescription)
                    walletClient.appError = error
                    walletClient.appState = .error
                }
            }
        }
    }
}

#if DEBUG
    #Preview {
        NetworkSettingsView(walletClient: .constant(WalletClient.mock))
    }
#endif
