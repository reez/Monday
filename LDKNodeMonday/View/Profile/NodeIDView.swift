//
//  NodeIDView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/21/23.
//

import BitcoinUI
import SwiftUI

struct NodeIDView: View {
    @ObservedObject var viewModel: NodeIDViewModel
    @State private var isCopied = false
    @State private var showCheckmark = false
    @State private var showingNodeIDErrorAlert = false
    @State private var isSeedPresented = false
    @State private var showingStopNodeConfirmation = false
    @State private var showingDeleteSeedConfirmation = false
    @State private var showingShowSeedConfirmation = false
    @State private var showingResetAppConfirmation = false
    @State private var isViewPeersPresented = false
    @State private var isAddChannelPresented = false
    @State private var refreshFlag = false
    @State private var isPaymentsPresented = false

    var body: some View {

        NavigationView {

            VStack {

                VStack(spacing: 10) {

                    HStack {
                        Image(systemName: "circle.fill")
                            .foregroundColor(
                                viewModel.status?.isRunning ?? false ? .green : .secondary
                            )
                        Text(
                            viewModel.status?.isRunning ?? false ? "On" : "Off"
                        )
                    }
                    .font(.caption2)

                    HStack {
                        Text(viewModel.nodeID)
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundColor(.primary)
                            .font(.subheadline)
                        Button(action: {
                            UIPasteboard.general.string = viewModel.nodeID
                            isCopied = true
                            showCheckmark = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isCopied = false
                                showCheckmark = false
                            }
                        }) {
                            Image(systemName: showCheckmark ? "checkmark" : "doc.on.doc")
                                .font(.subheadline)
                        }
                        .foregroundColor(viewModel.networkColor)
                    }

                    if let network = viewModel.network, let url = viewModel.esploraURL {
                        Text(
                            "\(network)".uppercased() + " "
                                + url.replacingOccurrences(of: "https://", with: "")
                                .replacingOccurrences(of: "http://", with: "")
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .foregroundColor(viewModel.networkColor)
                        .fontDesign(.monospaced)
                        .font(.caption2)
                    }

                }
                .padding(.all, 40.0)
                .fontDesign(.monospaced)

                List {

                    Section(
                        header: Text("Lightning".uppercased()).foregroundColor(
                            viewModel.networkColor
                        )
                    ) {

                        Button {
                            isViewPeersPresented = true
                        } label: {
                            Text("View Peers")
                        }

                        Button {
                            isAddChannelPresented = true
                        } label: {
                            Text("Add Channel")
                        }

                        NavigationLink("Channels") {
                            ChannelsRefactorView(viewModel: .init(nodeInfoClient: .live))
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
                            Button("Yes", role: .destructive) { viewModel.onboarding() }
                            Button("No", role: .cancel) {}
                        }

                        Button("Delete Seed") {
                            showingDeleteSeedConfirmation = true
                        }
                        .alert(
                            "Are you sure you want to delete the seed (and reset preferences)?",
                            isPresented: $showingDeleteSeedConfirmation
                        ) {
                            Button("Yes", role: .destructive) { viewModel.delete() }
                            Button("No", role: .cancel) {}
                        }
                    }
                    .foregroundColor(.primary)
                }
                .listRowSeparator(.hidden)
                .listStyle(.plain)
                .background(Color.clear)
                .navigationTitle("Profile")
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
                .sheet(
                    isPresented: $isAddChannelPresented,
                    onDismiss: {
                    }
                ) {
                    ChannelAddView(viewModel: .init())
                        .presentationDetents([.medium, .large])
                }

            }

        }

    }
}

struct NodeIDView_Previews: PreviewProvider {
    static var previews: some View {
        NodeIDView(viewModel: .init())
        NodeIDView(viewModel: .init())
            .environment(\.sizeCategory, .accessibilityLarge)
        NodeIDView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
