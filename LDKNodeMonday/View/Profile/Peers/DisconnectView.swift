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

        ZStack {
            Color(uiColor: UIColor.systemBackground)

            VStack {

                HStack {
                    Text("Node ID")
                    Text(viewModel.nodeId.description)
                        .truncationMode(.middle)
                        .lineLimit(1)
                        .foregroundColor(.secondary)

                }
                .font(.system(.caption, design: .monospaced))
                .padding()

                Button {
                    viewModel.disconnect()
                    if showingDisconnectViewErrorAlert == false {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    if showingDisconnectViewErrorAlert == true {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Text("Disconnect Peer")
                        .bold()
                        .foregroundColor(Color(uiColor: UIColor.systemBackground))
                        .frame(maxWidth: .infinity)
                        .padding(.all, 8)
                }
                .buttonBorderShape(.capsule)
                .buttonStyle(.borderedProminent)
                .frame(width: 300, height: 50)
                .tint(viewModel.networkColor)
                .padding()

            }
            .padding()
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
        .ignoresSafeArea()

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
