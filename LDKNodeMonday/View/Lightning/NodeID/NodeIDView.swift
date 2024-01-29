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

    var body: some View {

        NavigationView {

            ZStack {
                Color(uiColor: UIColor.systemBackground)

                VStack(spacing: 20.0) {

                    VStack {

                        Spacer()

                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(viewModel.networkColor)

                        HStack(alignment: .center) {
                            Text(viewModel.nodeID)
                                .frame(width: 200, height: 50)
                                .truncationMode(.middle)
                                .lineLimit(1)
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                            Button {
                                UIPasteboard.general.string = viewModel.nodeID
                                isCopied = true
                                showCheckmark = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    isCopied = false
                                    showCheckmark = false
                                }
                            } label: {
                                HStack {
                                    withAnimation {
                                        Image(
                                            systemName: showCheckmark ? "checkmark" : "doc.on.doc"
                                        )
                                        .font(.subheadline)
                                    }
                                }
                                .bold()
                                .foregroundColor(viewModel.networkColor)
                            }

                        }
                        .padding(.horizontal)
                    }
                    .padding()

                    VStack(spacing: 10) {
                        VStack {
                            Text("Danger Zone")
                                .bold()
                            Text("Desperate times call for desperate measures")
                                .italic()
                                .font(.caption)
                        }
                        .foregroundColor(.red)
                        .padding()

                        VStack(spacing: 20) {

                            Button {
                                showingShowSeedConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "list.number")
                                    Text("Show Seed")
                                }
                                .foregroundColor(Color(uiColor: UIColor.systemBackground))
                                .bold()
                                .frame(width: 200)
                            }
                            .buttonBorderShape(.capsule)
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                            .alert(
                                "Are you sure you want to view the seed?",
                                isPresented: $showingShowSeedConfirmation
                            ) {
                                Button("Yes", role: .destructive) {
                                    isSeedPresented = true
                                }
                                Button("No", role: .cancel) {}
                            }

                            Button {
                                showingStopNodeConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "xmark")
                                    Text("Stop Node")
                                }
                                .foregroundColor(Color(uiColor: UIColor.systemBackground))
                                .bold()
                                .frame(width: 200)
                            }
                            .buttonBorderShape(.capsule)
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                            .alert(
                                "Are you sure you want to stop the node?",
                                isPresented: $showingStopNodeConfirmation
                            ) {
                                Button("Yes", role: .destructive) {
                                    viewModel.stop()
                                }
                                Button("No", role: .cancel) {}
                            }

                            Button {
                                showingResetAppConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.uturn.backward")
                                    Text("Reset Preferences")
                                }
                                .foregroundColor(Color(uiColor: UIColor.systemBackground))
                                .bold()
                                .frame(width: 200)
                            }
                            .buttonBorderShape(.capsule)
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                            .alert(
                                "Are you sure you want to reset preferences?",
                                isPresented: $showingResetAppConfirmation
                            ) {
                                Button("Yes", role: .destructive) {
                                    viewModel.onboarding()
                                }
                                Button("No", role: .cancel) {}
                            }

                            Button {
                                showingDeleteSeedConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "minus")
                                    Text("Delete Seed")
                                }
                                .foregroundColor(Color(uiColor: UIColor.systemBackground))
                                .bold()
                                .frame(width: 200)
                            }
                            .buttonBorderShape(.capsule)
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                            .alert(
                                "Are you sure you want to reset preferences and delete the seed?",
                                isPresented: $showingDeleteSeedConfirmation
                            ) {
                                Button("Yes", role: .destructive) {
                                    viewModel.delete()
                                }
                                Button("No", role: .cancel) {}
                            }

                        }
                        .padding()
                        .padding(.bottom, 120.0)
                    }
                    .padding()

                }
                .padding()
                .navigationTitle("Node ID")
                .alert(isPresented: $showingNodeIDErrorAlert) {
                    Alert(
                        title: Text(viewModel.nodeIDError?.title ?? "Unknown"),
                        message: Text(viewModel.nodeIDError?.detail ?? ""),
                        dismissButton: .default(Text("OK")) {
                            viewModel.nodeIDError = nil
                        }
                    )
                }
                .onReceive(viewModel.$nodeIDError) { errorMessage in
                    if errorMessage != nil {
                        showingNodeIDErrorAlert = true
                    }
                }
                .onAppear {
                    Task {
                        viewModel.getNodeID()
                        viewModel.getColor()
                    }
                }
                .sheet(
                    isPresented: $isSeedPresented
                ) {
                    SeedView(viewModel: .init())
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }

            }
            .ignoresSafeArea()

        }

    }

}

struct NodeIDView_Previews: PreviewProvider {
    static var previews: some View {
        NodeIDView(viewModel: .init())
        NodeIDView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
