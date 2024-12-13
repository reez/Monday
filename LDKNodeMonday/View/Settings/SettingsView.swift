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
    @State private var isCopied = false
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

                Section(
                    header: Text("Wallet")
                ) {
                    HStack {
                        Image(systemName: "network")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text("Network")
                        Spacer()
                        Text((viewModel.network ?? "No network").capitalized)
                            .foregroundColor(.secondary)
                    }

                    NavigationLink(destination: SeedView(viewModel: .init())) {
                        HStack {
                            Image(systemName: "lock")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                            Text("Backup")
                        }
                    }

                }

                Section(
                    header: Text("Lightning node")
                ) {
                    HStack {
                        Image(systemName: "bolt")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text("Node Id")
                        Spacer()
                        Text(viewModel.nodeID)
                            .foregroundColor(.secondary)
                            .frame(width: 150)
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .padding(.horizontal)
                        Button {
                            UIPasteboard.general.string = viewModel.nodeID
                        } label: {
                            Image(systemName: "doc.on.doc")
                        }
                    }

                    NavigationLink(
                        destination: ChannelsListView(viewModel: .init(nodeInfoClient: .live))
                    ) {
                        HStack {
                            Image(systemName: "fibrechannel")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                            Text("Channels")
                        }
                    }

                    NavigationLink(destination: PeersListView(viewModel: .init())) {
                        HStack {
                            Image(systemName: "person.line.dotted.person")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                            Text("Peers")
                        }
                    }
                    
                    HStack {
                        Image(systemName: "power")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text("Status")
                        Spacer()
                        HStack {
                            Text(viewModel.status?.isRunning ?? false ? "On" : "Off")
                                .foregroundColor(.secondary)
                        }
                    }

                }

                Section(header: Text("Danger Zone".uppercased()).foregroundColor(.red)) {
                    /*
                        Button("Show Seed") {
                            showingShowSeedConfirmation = true
                        }
                        .alert(
                            "Are you sure you want to view the seed?",
                            isPresented: $showingShowSeedConfirmation
                        ) {
                            Button("Yes", role: .destructive) { isSeedPresented = true }
                            Button("No", role: .cancel) {}
                        }
                         */

                    HStack {
                        Image(systemName: "exclamationmark.octagon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Button("Stop Node") {
                            showingStopNodeConfirmation = true
                        }
                        .alert(
                            "Are you sure you want to stop the node?",
                            isPresented: $showingStopNodeConfirmation
                        ) {
                            Button("Yes", role: .destructive) { viewModel.stop() }
                            Button("No", role: .cancel) {}
                        }
                    }

                    HStack {
                        Image(systemName: "minus.diamond")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Button("Reset Preferences") {
                            showingResetAppConfirmation = true
                        }
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
                    }

                    HStack {
                        Image(systemName: "delete.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Button("Delete Seed") {
                            showingDeleteSeedConfirmation = true
                        }
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
                    }
                }
                .foregroundColor(.primary)
            }.dynamicTypeSize(...DynamicTypeSize.accessibility1)  // Sets max dynamic size for all Text
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
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
                        viewModel.getColor()
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
