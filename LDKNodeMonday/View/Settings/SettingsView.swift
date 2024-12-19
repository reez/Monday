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
    @ObservedObject var viewModel: NodeIDViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showCheckmark = false
    @State private var showingNodeIDErrorAlert = false
    @State private var isSeedPresented = false
    @State private var showingStopNodeConfirmation = false
    @State private var showingDeleteSeedConfirmation = false
    @State private var showingShowSeedConfirmation = false
    @State private var showingResetAppConfirmation = false
    @State private var isViewPeersPresented = false
    @State private var refreshFlag = false
    @State private var isPaymentsPresented = false

    @State private var showGreeting = true

    var body: some View {

        NavigationView {
            Form {

                // Wallet

                Section {
                    Label("Network", systemImage: "network")
                        .badge((viewModel.network ?? "No network").capitalized)

                    NavigationLink(destination: SeedView(viewModel: .init())) {
                        Label("Recovery Phrase", systemImage: "lock")
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
                        showingStopNodeConfirmation = true
                    } label: {
                        Text("Stop Node")  //, systemImage: "exclamationmark.octagon")
                    }.foregroundColor(.red)
                        .alert(
                            "Are you sure you want to stop the node?",
                            isPresented: $showingStopNodeConfirmation
                        ) {
                            Button("Yes", role: .destructive) { viewModel.stop() }
                            Button("No", role: .cancel) {}
                        }

                    Button {
                        showingResetAppConfirmation = true
                    } label: {
                        Text("Reset Preferences")  //, systemImage: "minus.diamond")
                    }.foregroundColor(.red)
                        .alert(
                            "Are you sure you want to reset preferences (and delete the seed)?",
                            isPresented: $showingResetAppConfirmation
                        ) {
                            Button("Yes", role: .destructive) {
                                viewModel.onboarding()
                                dismiss()
                            }
                            Button("No", role: .cancel) {}
                        }

                    Button {
                        showingDeleteSeedConfirmation = true
                    } label: {
                        Text("Delete Seed")  //, systemImage: "delete.left")
                    }.foregroundColor(.red)
                        .alert(
                            "Are you sure you want to delete the seed (and reset preferences)?",
                            isPresented: $showingDeleteSeedConfirmation
                        ) {
                            Button("Yes", role: .destructive) {
                                viewModel.delete()
                                dismiss()
                            }
                            Button("No", role: .cancel) {}
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
                    showingNodeIDErrorAlert = errorMessage != nil
                }
                .alert(isPresented: $showingNodeIDErrorAlert) {
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
        SettingsView(viewModel: .init())
    }
#endif
