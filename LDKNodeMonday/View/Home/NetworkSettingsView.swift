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

    @EnvironmentObject var viewModel: NetworkSettingsViewModel

    var body: some View {

        VStack {
            Form {
                Section {
                    Picker(
                        "Network",
                        selection: $viewModel.selectedNetwork
                    ) {
                        Text("Signet").tag(Network.signet)
                        Text("Testnet").tag(Network.testnet)
                    }
                    .pickerStyle(.navigationLink)
                    .accessibilityLabel("Select bitcoin network")

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
                } footer: {
                    Text(
                        "Set your desired network and connection server.\nIf in doubt, use the default settings."
                    )
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
        NetworkSettingsView(viewModel: .init())
    }
#endif
