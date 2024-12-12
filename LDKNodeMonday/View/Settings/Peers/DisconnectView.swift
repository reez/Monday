//
//  DisconnectView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/2/23.
//

import BitcoinUI
import SwiftUI

struct DisconnectView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: DisconnectViewModel
    @State private var showingDisconnectViewErrorAlert = false

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
                    viewModel.disconnect()
                    if showingDisconnectViewErrorAlert == false {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    if showingDisconnectViewErrorAlert == true {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Text("Disconnect")
                        .fontWeight(.medium)
                        .padding()
                }
            }
        }
        .alert(isPresented: $showingDisconnectViewErrorAlert) {
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
                showingDisconnectViewErrorAlert = true
            }
        }
        .onAppear {
            viewModel.getColor()
        }

    }

}

#if DEBUG
    #Preview {
        DisconnectView(
            viewModel: .init(
                nodeId: "03e39c737a691931dac0f9f9ee803f2ab08f7fd3bbb25ec08d9b8fdb8f51d3a8db"
            )
        )
    }
#endif
