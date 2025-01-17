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

    var body: some View {
        NavigationView {
            SettingsFormView(
                viewModel: viewModel,
                showCheckmark: $showCheckmark,
                showStopNodeConfirmation: $showStopNodeConfirmation,
                showDeleteSeedConfirmation: $showDeleteSeedConfirmation,
                dismiss: dismiss
            )
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .listStyle(.plain)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
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

struct SettingsFormView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Binding var showCheckmark: Bool
    @Binding var showStopNodeConfirmation: Bool
    @Binding var showDeleteSeedConfirmation: Bool
    let dismiss: DismissAction

    var body: some View {
        Form {
            WalletSection(viewModel: viewModel)
            LightningNodeSection(
                viewModel: viewModel,
                showCheckmark: $showCheckmark
            )
            DangerZoneSection(
                viewModel: viewModel,
                showStopNodeConfirmation: $showStopNodeConfirmation,
                showDeleteSeedConfirmation: $showDeleteSeedConfirmation,
                dismiss: dismiss
            )
        }
    }
}

private struct WalletSection: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Section {
            NavigationLink(
                destination: SeedView(viewModel: .init(lightningClient: viewModel.lightningClient))
            ) {
                Label("Recovery Phrase", systemImage: "lock")
            }

            Label("Network", systemImage: "network")
                .badge((viewModel.network ?? "No network").capitalized)

            Label("Server", systemImage: "server.rack")
                .badge(
                    viewModel.esploraURL?.replacingOccurrences(of: "https://", with: "")
                        .replacingOccurrences(of: "http://", with: "") ?? "No server"
                )
        } header: {
            Text("Wallet").foregroundColor(.primary)
        }
        .foregroundColor(.primary)
    }
}

private struct LightningNodeSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Binding var showCheckmark: Bool

    var body: some View {
        Section {
            NodeIDRow(viewModel: viewModel, showCheckmark: $showCheckmark)

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
        } header: {
            Text("Lightning Node").foregroundColor(.primary)
        }
        .foregroundColor(.primary)
    }
}

private struct NodeIDRow: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Binding var showCheckmark: Bool

    var body: some View {
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
    }
}

private struct DangerZoneSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Binding var showStopNodeConfirmation: Bool
    @Binding var showDeleteSeedConfirmation: Bool
    let dismiss: DismissAction

    var body: some View {
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
                    viewModel.delete()
                    dismiss()
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
}

#if DEBUG
    #Preview {
        SettingsView(viewModel: .init(appState: .constant(.onboarding), lightningClient: .mock))
    }
#endif
