//
//  StartView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/17/23.
//

import SwiftUI
import WalletUI

struct StartView: View {
    @ObservedObject var viewModel: StartViewModel
    @State private var showingErrorAlert = false

    var body: some View {
        
        ZStack {
            Color(uiColor: UIColor.systemBackground)
            
            VStack {
                if viewModel.isStarted {
                    TabHomeView(viewModel: .init())
                } else {
                    Text("Starting...")
                    ProgressView()
                }
            }
            .padding()
            .tint(viewModel.networkColor)
            .onAppear {
                Task {
                    try await viewModel.start()
                    viewModel.getColor()
                }
            }
            .alert(isPresented: $showingErrorAlert) {
                Alert(
                    title: Text(viewModel.errorMessage?.title ?? "Unknown"),
                    message: Text(viewModel.errorMessage?.detail ?? ""),
                    dismissButton: .default(Text("OK")) {
                        viewModel.errorMessage = nil
                    }
                )
            }
            
        }
        .ignoresSafeArea()
        
    }
    
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView(viewModel: .init())
    }
}
