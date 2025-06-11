//
//  LSPSettingsView.swift
//  LDKNodeMonday
//
//  Created by Daniel Nordh on 23/05/2025.
//

import LDKNode
import SwiftUI

struct LSPSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var walletClient: WalletClient
    @State private var showRestartAlert = false
    @State private var currentLSP: LightningServiceProvider

    // Initialize the local state in the initializer
    init(walletClient: Binding<WalletClient>) {
        self._walletClient = walletClient
        self._currentLSP = State(initialValue: walletClient.wrappedValue.lsp)
    }

    var body: some View {
        VStack {
            Form {
                Section {
                    // Simplified the ForEach binding by first calculating availableLSPs
                    let availableLSPsList = availableLSPs(network: walletClient.network)
                    Picker("LSP", selection: $currentLSP) {
                        ForEach(availableLSPsList, id: \.nodeId) { lsp in
                            Text(lsp.name).tag(lsp)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .accessibilityLabel("Select LSP")
                    .onChange(of: currentLSP) { oldValue, newValue in
                        if walletClient.appState == .onboarding {
                            walletClient.lsp = currentLSP
                        } else {
                            showRestartAlert = true
                        }
                    }
                } footer: {
                    Text(
                        "Set your desired Lightning Service Provider.\nIf in doubt, use the default settings."
                    )
                }
                .alert("Change and restart?", isPresented: $showRestartAlert) {
                    Button("Cancel", role: .cancel) {
                        // Reset state to match wallet client on cancel
                        currentLSP = walletClient.lsp
                    }
                    Button("Restart") {
                        handleRestart()
                    }
                } message: {
                    Text("Changing settings requires a restart of your node.")
                }
            }
            .navigationTitle("LSP settings")
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

    private func handleRestart() {
        Task {
            do {
                try KeyClient.live.saveLSP(currentLSP.nodeId)
                await walletClient.restart(
                    newNetwork: walletClient.network,
                    newServer: walletClient.server,
                    lsp: currentLSP
                )
            } catch {
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
        LSPSettingsView(walletClient: .constant(WalletClient(appMode: AppMode.mock)))
    }
#endif
