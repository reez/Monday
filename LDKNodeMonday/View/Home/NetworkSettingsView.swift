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

    var body: some View {

        VStack {
            Form {
                Section {
                    Picker(
                        "Network",
                        selection: Binding(
                            get: { walletClient.network },
                            set: { newNetwork in
                                if walletClient.appState == .onboarding {
                                    walletClient.network = newNetwork
                                    guard let server = availableServers(network: newNetwork).first
                                    else {
                                        // This should never happen, but if it does:
                                        fatalError("No servers available for \(newNetwork)")
                                    }
                                    walletClient.server = server
                                } else {
                                    tempNetwork = newNetwork
                                    showRestartAlert = true
                                }
                            }
                        )
                    ) {
                        Text("Signet").tag(Network.signet)
                        Text("Testnet").tag(Network.testnet)
                    }
                    .pickerStyle(.navigationLink)
                    .accessibilityLabel("Select bitcoin network")

                    Picker(
                        "Server",
                        selection: Binding(
                            get: { walletClient.server },
                            set: { newServer in
                                if walletClient.appState == .onboarding {
                                    walletClient.server = newServer
                                } else {
                                    tempServer = newServer
                                    showRestartAlert = true
                                }
                            }
                        )
                    ) {
                        ForEach(
                            availableServers(network: walletClient.network),
                            id: \.self
                        ) { esploraServer in
                            Text(esploraServer.name).tag(esploraServer)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .accessibilityLabel("Select esplora server")
                } footer: {
                    Text(
                        "Set your desired network and connection server.\nIf in doubt, use the default settings."
                    )
                }
                .alert("Change and restart?", isPresented: $showRestartAlert) {
                    Button("Cancel", role: .cancel) {}
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
            Task {
                let newNetwork = tempNetwork ?? walletClient.network
                guard let server = availableServers(network: newNetwork).first
                else {
                    // This should never happen, but if it does:
                    fatalError("No servers available for \(newNetwork)")
                }
                let newServer = tempServer ?? server

                do {
                    try KeyClient.live.saveNetwork(newNetwork.description)
                    try KeyClient.live.saveServerURL(newServer.url)
                } catch let error {
                    await MainActor.run {
                        debugPrint(error.localizedDescription)
                        walletClient.appError = error
                        walletClient.appState = .error
                    }
                }

                await walletClient.restart(
                    newNetwork: newNetwork,
                    newServer: newServer
                )
            }
        }
    }
}

#if DEBUG
    #Preview {
        NetworkSettingsView(walletClient: .constant(WalletClient(keyClient: KeyClient.mock)))
    }
#endif
