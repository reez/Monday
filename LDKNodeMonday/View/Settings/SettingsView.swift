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
    @Binding var walletClient: WalletClient
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showCheckmark = false
    @State private var showNodeIDErrorAlert = false
    @State private var showStopNodeConfirmation = false
    @State private var showDeleteSeedConfirmation = false
    @State private var showResetAppConfirmation = false

    var body: some View {

        NavigationView {
            Form {

                // Wallet

                Section {
                    NavigationLink(destination: SeedView(viewModel: .init())) {
                        Label("Recovery Phrase", systemImage: "lock")
                    }

                    NavigationLink(
                        destination: NetworkSettingsView(walletClient: $walletClient)
                            .environmentObject(viewModel)
                    ) {
                        Label("Network", systemImage: "network")
                            .badge((viewModel.network ?? "No network").capitalized)
                    }

                } header: {
                    Text("Wallet")
                        .foregroundColor(.primary)
                }.foregroundColor(.primary)

                // Lightning node

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
                        destination: ChannelsListView(viewModel: .init(nodeInfoClient: .live))
                    ) {
                        Label("Channels", systemImage: "fibrechannel")
                    }

                    NavigationLink(destination: PeersListView(viewModel: .init())) {
                        Label("Peers", systemImage: "person.line.dotted.person")
                    }

                } header: {
                    Text("Lightning Node")
                        .foregroundColor(.primary)
                }.foregroundColor(.primary)

                // Danger zone

                Section {

                    Button {
                        showStopNodeConfirmation = true
                    } label: {
                        Text("Stop Node")
                    }.foregroundColor(.red)
                        .alert(
                            "Warning!",
                            isPresented: $showStopNodeConfirmation
                        ) {
                            Button("Yes", role: .destructive) { viewModel.stop() }
                            Button("No", role: .cancel) {}
                        } message: {
                            Text("Are you sure you want to stop the node?")
                        }

                    Button {
                        showDeleteSeedConfirmation = true
                    } label: {
                        Text("Delete Wallet")
                    }.foregroundColor(.red)
                        .alert("Warning!", isPresented: $showDeleteSeedConfirmation) {
                            Button("Yes", role: .destructive) {
                                viewModel.delete()
                                dismiss()
                            }
                            Button("No", role: .cancel) {}
                        } message: {
                            Text(
                                "All funds will be lost. Are you sure you want to delete the wallet?"
                            )
                        }

                    Button {
                        showResetAppConfirmation = true
                    } label: {
                        Text("Full Reset")
                    }.foregroundColor(.red)
                        .alert(
                            "Warning!",
                            isPresented: $showResetAppConfirmation
                        ) {
                            Button("Yes", role: .destructive) {
                                viewModel.onboarding()
                                dismiss()
                            }
                            Button("No", role: .cancel) {}
                        } message: {
                            Text(
                                "The wallet and all data will be lost. Are you sure you want to fully reset the app?"
                            )
                        }

                } header: {
                    Text("Danger Zone")
                }.foregroundColor(.primary)

            }.dynamicTypeSize(...DynamicTypeSize.accessibility1)  // Sets max dynamic size for all Text
                .listStyle(.plain)
                //.scrollContentBackground(.hidden) // uncomment if we want white background
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
                .onAppear {
                    Task {
                        viewModel.getNodeID()
                        viewModel.getNetwork()
                        viewModel.getEsploraUrl()
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
        }

    }
}

#if DEBUG
    #Preview {
        SettingsView(
            walletClient: .constant(WalletClient(keyClient: KeyClient.mock)),
            viewModel: .init()
        )
    }
#endif
