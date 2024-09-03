//
//  StartView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/17/23.
//

import BitcoinUI
import LDKNode
import SwiftUI

struct StartView: View {
    @ObservedObject var viewModel: StartViewModel
    @State private var showingStartViewErrorAlert = false
    @State var startViewError: MondayError?

    var body: some View {

        ZStack {
            Color(uiColor: UIColor.systemBackground)
                .ignoresSafeArea()

            if viewModel.isStarted {
                BitcoinView(viewModel: .init(priceClient: .live))
                    .edgesIgnoringSafeArea(.all)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "bolt.horizontal")
                        .symbolEffect(.pulse.wholeSymbol)
                        .foregroundColor(
                            Color(red: 119 / 255, green: 243 / 255, blue: 205 / 255)
                        )
                        .padding()
                    Button {
                        viewModel.onboarding()
                    } label: {
                        HStack {
                            Image(systemName: "arrowshape.backward")
                                .minimumScaleFactor(0.5)
                            Text("Onboarding")
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                        .foregroundColor(Color(uiColor: UIColor.systemBackground))
                        .frame(width: 200, height: 25)
                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.bordered)
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: UIColor.systemBackground))
            }
        }
        .onAppear {
            Task {
                do {
                    try await viewModel.start()
                    viewModel.getColor()
                } catch let error as NodeError {
                    let errorString = handleNodeError(error)
                    DispatchQueue.main.async {
                        self.startViewError = .init(
                            title: errorString.title,
                            detail: errorString.detail
                        )
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.startViewError = .init(
                            title: "Unexpected error",
                            detail: error.localizedDescription
                        )
                    }
                }
            }
        }
        .alert(isPresented: $showingStartViewErrorAlert) {
            Alert(
                title: Text(viewModel.startViewError?.title ?? "Unknown"),
                message: Text(viewModel.startViewError?.detail ?? ""),
                dismissButton: .default(Text("OK")) {
                    viewModel.startViewError = nil
                }
            )
        }
    }

}

#if DEBUG
#Preview {
    StartView(viewModel: .init())
}
#endif
