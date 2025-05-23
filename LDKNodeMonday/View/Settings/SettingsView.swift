//
//  SettingsView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/21/23.
//

import BitcoinUI
import LDKNode
import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showCheckmark = false
    @State private var showNodeIDErrorAlert = false
    @State private var showStopNodeConfirmation = false
    @State private var showDeleteSeedConfirmation = false
    @State private var showToggleTestData = false

    var body: some View {
        VStack {
            Form {
                // Wallet section
                Section {
                    NavigationLink(
                        destination: SeedView(
                            viewModel: .init(lightningClient: viewModel.lightningClient)
                        )
                    ) {
                        Label("Recovery Phrase", systemImage: "lock")
                    }

                    NavigationLink(
                        destination: NetworkSettingsView(walletClient: $viewModel.walletClient)

                    ) {
                        Label("Network", systemImage: "network")
                            .badge((viewModel.network ?? "No network").capitalized)
                    }
                } header: {
                    Text("Wallet").foregroundColor(.primary)
                }

                // Lightning Node section
                Section {
                    HStack {
                        Label("ID", systemImage: "bolt")
                        Spacer()
                        Text(viewModel.nodeID)
                            .frame(width: 150)
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                        Button {
                            UIPasteboard.general.string = viewModel.nodeID
                            showCheckmark = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showCheckmark = false
                            }
                        } label: {
                            Image(systemName: showCheckmark ? "checkmark" : "doc.on.doc")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(showCheckmark ? .secondary : .accentColor)
                                .accessibilityLabel(showCheckmark ? "Copied" : "Copy node ID")
                        }
                    }

                    Label("Status", systemImage: "power")
                        .badge(viewModel.status?.isRunning ?? false ? "On" : "Off")

                    NavigationLink(
                        destination: ChannelsListView(
                            viewModel: .init(
                                nodeInfoClient: .live,
                                lightningClient: viewModel.lightningClient
                            )
                        )
                    ) {
                        Label("Channels", systemImage: "fibrechannel")
                    }

                    NavigationLink(
                        destination: PeersListView(
                            viewModel: .init(lightningClient: viewModel.lightningClient)
                        )
                    ) {
                        Label("Peers", systemImage: "person.line.dotted.person")
                    }

                    NavigationLink(
                        destination: LSPSettingsView(walletClient: $viewModel.walletClient)

                    ) {
                        Label("LSP", systemImage: "rays")
                            .badge((viewModel.walletClient.lsp.name).capitalized)
                    }
                } header: {
                    Text("Lightning Node").foregroundColor(.primary)
                }

                // Developer section
                Section {
                    Toggle(
                        isOn: Binding(
                            get: { viewModel.walletClient.appMode == .mock },
                            set: { _ in
                                showToggleTestData = true
                            }
                        ),
                        label: { Label("Use mock data", systemImage: "testtube.2") }
                    )
                    NavigationLink(
                        destination: LogFilesView()
                    ) {
                        Label(
                            "Log files",
                            systemImage: "line.3.horizontal.button.angledtop.vertical.right"
                        )
                    }
                    Link(destination: URL(string: "https://github.com/reez/Monday/issues/new")!) {
                        Label("Open a GitHub Issue", systemImage: "ladybug")
                    }
                } header: {
                    Text("Design & Develop").foregroundColor(.primary)
                }

                // Danger Zone section
                Section {
                    Button {
                        showStopNodeConfirmation = true
                    } label: {
                        Text("Stop Node")
                    }
                    .foregroundColor(.red)
                    .alert("Warning!", isPresented: $showStopNodeConfirmation) {
                        Button("Yes", role: .destructive) { viewModel.stop() }
                        Button("No", role: .cancel) {}
                    } message: {
                        Text("Are you sure you want to stop the node?")
                    }

                    Button {
                        showDeleteSeedConfirmation = true
                    } label: {
                        Text("Delete Wallet")
                    }
                    .foregroundColor(.red)
                    .alert("Warning!", isPresented: $showDeleteSeedConfirmation) {
                        Button("Yes", role: .destructive) {
                            Task {
                                await viewModel.walletClient.delete()
                                dismiss()
                            }
                        }
                        Button("No", role: .cancel) {}
                    } message: {
                        Text("All funds will be lost.\nAre you sure you want to delete the wallet?")
                    }
                } header: {
                    Text("Danger Zone").foregroundColor(.primary)
                }
                .foregroundColor(.primary)
            }
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .listStyle(.plain)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    viewModel.getNodeID()
                    viewModel.getNetwork()
                    viewModel.getServerUrl()
                    await viewModel.getStatus()
                }
            }
            .onReceive(viewModel.$nodeIDError) { errorMessage in
                showNodeIDErrorAlert = errorMessage != nil
            }
            .alert(isPresented: $showNodeIDErrorAlert) {
                Alert(
                    title: Text(viewModel.nodeIDError?.title ?? "Unknown"),
                    message: Text(viewModel.nodeIDError?.detail ?? ""),
                    dismissButton: .default(Text("OK")) {
                        viewModel.nodeIDError = nil
                    }
                )
            }
            .alert("Change and restart?", isPresented: $showToggleTestData) {
                Button("Cancel", role: .cancel) {}
                Button("Restart") {
                    Task {
                        await viewModel.walletClient.restart(
                            newNetwork: viewModel.walletClient.network,
                            newServer: viewModel.walletClient.server,
                            appMode: viewModel.walletClient.appMode == .mock ? .live : .mock
                        )
                        dismiss()
                    }
                }
            } message: {
                Text("This change requires a restart of your node.")
            }
        }
    }
}

#if DEBUG
    #Preview {
        SettingsView(
            viewModel: .init(
                walletClient: .constant(WalletClient(appMode: AppMode.mock)),
                lightningClient: .mock
            )

        )
    }
#endif
