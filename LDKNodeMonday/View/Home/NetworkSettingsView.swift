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
                                tempNetwork = newNetwork
                                if walletClient.appState == .onboarding {
                                    walletClient.network = tempNetwork!
                                    walletClient.server =
                                        walletClient.availableEsploraServers().first
                                        ?? EsploraServer(name: "", url: "")
                                } else {
                                    walletClient.network = tempNetwork!
                                    walletClient.server =
                                        walletClient.availableEsploraServers().first
                                        ?? EsploraServer(name: "", url: "")
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
                                tempServer = newServer
                                if walletClient.appState == .onboarding {
                                    walletClient.server = tempServer!
                                } else {
                                    tempNetwork = walletClient.network
                                    showRestartAlert = true
                                }
                            }
                        )
                    ) {
                        ForEach(walletClient.availableEsploraServers(), id: \.self) {
                            esploraServer in
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
                        if tempNetwork != nil || tempServer != nil {
                            Task {
                                await walletClient.restart(
                                    newNetwork: tempNetwork,
                                    newServer: tempServer
                                )
                            }
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
            }.tint(.accentColor)
        }
    }
}

#if DEBUG
    #Preview {
        NetworkSettingsView(
            walletClient: .constant(WalletClient(keyClient: KeyClient.mock))
        )
    }
#endif
