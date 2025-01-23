//
//  NetworkSettingsView.swift
//  LDKNodeMonday
//
//  Created by Daniel Nordh on 03/12/2024.
//

import LDKNode
import SwiftUI

struct NetworkSettingsView: View {
    let lightningClient: LightningNodeClient
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: NetworkSettingsViewModel

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
                            get: { viewModel.selectedNetwork },
                            set: { newNetwork in
                                if viewModel.appState == .onboarding {
                                    viewModel.selectedNetwork = newNetwork
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
                            get: { viewModel.selectedEsploraServer },
                            set: { newServer in
                                if viewModel.appState == .onboarding {
                                    viewModel.selectedEsploraServer = newServer
                                } else {
                                    tempServer = newServer
                                    tempNetwork = viewModel.selectedNetwork
                                    showRestartAlert = true
                                }
                            }
                        )
                    ) {
                        ForEach(
                            availableServers(network: viewModel.selectedNetwork),
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
                        if tempNetwork != nil || tempServer != nil {
                            Task {
                                // TODO: Where should restart live? Needs to set AppState, and save BackupInfo)
                                do {
                                    let newNetwork =
                                        tempNetwork != nil
                                        ? tempNetwork! : viewModel.selectedNetwork
                                    let newServer =
                                        tempServer != nil
                                        ? tempServer! : availableServers(network: newNetwork).first!

                                    try KeyClient.live.saveNetwork(newNetwork.description)
                                    try KeyClient.live.saveServerURL(newServer.url)

                                    do {
                                        //self.appState = .loading
                                        try await lightningClient.restart()
//                                        await MainActor.run {
//                                            self.appState = .wallet
//                                        }
                                    } catch let error {
                                        debugPrint(error)  // TODO: Show error on relevant screen
                                        //self.appError = error
                                    }
                                } catch {
                                    /*
                                         DispatchQueue.main.async {
                                             self.onboardingViewError = .init(
                                                 title: "Error Selecting Network",
                                                 detail: error.localizedDescription
                                             )
                                         }
                                         */
                                }
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
            }
        }
        .tint(.accentColor)
    }
}

#if DEBUG
    #Preview {
        NetworkSettingsView(lightningClient: .mock, viewModel: .init())
    }
#endif
