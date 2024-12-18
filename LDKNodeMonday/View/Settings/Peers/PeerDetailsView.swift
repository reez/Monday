//
//  DisconnectView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/2/23.
//

import SwiftUI

struct PeerDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: DisconnectViewModel
    @State private var showDisconnectAlert = false
    @State private var showErrorAlert = false

    var body: some View {

        VStack {

            List {
                VStack(alignment: .leading) {
                    Text("Node ID")
                        .font(.subheadline.weight(.medium))
                    Text(viewModel.nodeId.description)
                        //.frame(width: 100)
                        .truncationMode(.middle)
                        .lineLimit(1)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 5)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)

            Spacer()

        }
        .navigationTitle("Peer details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    self.showDisconnectAlert = true
                } label: {
                    Text("Disconnect")
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }.alert(
            "Are you sure you want to disconnect from this peer?",
            isPresented: $showDisconnectAlert
        ) {
            Button("Yes", role: .destructive) {
                viewModel.disconnect()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
            Button("No", role: .cancel) {}
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text(viewModel.disconnectViewError?.title ?? "Unknown"),
                message: Text(viewModel.disconnectViewError?.detail ?? ""),
                dismissButton: .default(Text("OK")) {
                    viewModel.disconnectViewError = nil
                }
            )
        }
        .onReceive(viewModel.$disconnectViewError) { errorMessage in
            if errorMessage != nil {
                showErrorAlert = true
            }
        }
        .onAppear {
            viewModel.getColor()
        }

    }

}

#if DEBUG
    #Preview {
        PeerDetailsView(
            viewModel: .init(
                nodeId: "03e39c737a691931dac0f9f9ee803f2ab08f7fd3bbb25ec08d9b8fdb8f51d3a8db"
            )
        )
    }
#endif
