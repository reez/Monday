//
//  SettingsView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/21/23.
//

import BitcoinUI
import SwiftUI
import LDKNode

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

    var body: some View {

        NavigationView {

                List {

                    Section(
                        header: Text("Lightning node details")
                    ) {
                        HStack {
                            Text("Network")
                            Spacer()
                            Text((viewModel.network ?? "No network").capitalized)
                        }
                        
                        HStack {
                            Text("Node Id")
                            Spacer()
                            Text(viewModel.nodeID)
                                .frame(width: 200)
                                .truncationMode(.middle)
                                .lineLimit(1)
                            Button {
                                UIPasteboard.general.string = viewModel.nodeID
                            } label: {
                                Image(systemName: "doc.on.doc")
                            }
                        }
                        
                        HStack {
                            Text("Status")
                            Spacer()
                            HStack {
                                Text(viewModel.status?.isRunning ?? false ? "On" : "Off")
                                Image(systemName: "circle.fill")
                                    .foregroundColor(
                                        viewModel.status?.isRunning ?? false ? .green : .red
                                    )
                            }
                        }
                        
                        NavigationLink("Channels") {
                            ChannelsListView(viewModel: .init(nodeInfoClient: .live))
                        }

                        Button {
                            isViewPeersPresented = true
                        } label: {
                            Text("View Peers")
                        }

                    }
                    .foregroundColor(.primary)

                    Section(header: Text("Danger Zone".uppercased()).foregroundColor(.red)) {
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
                    .foregroundColor(.primary)
                }
                .listRowSeparator(.hidden)
                .listStyle(.plain)
                .background(Color.clear)
                .navigationTitle("Settings")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }.padding()
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
                .sheet(isPresented: $isSeedPresented) {
                    SeedView(viewModel: .init())
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
                .sheet(
                    isPresented: $isViewPeersPresented,
                    onDismiss: {
                    }
                ) {
                    PeersListView(viewModel: .init())
                        .presentationDetents([.medium])
                }

        }

    }
}

#if DEBUG
    #Preview {
        SettingsView(viewModel: .init())
    }
#endif
