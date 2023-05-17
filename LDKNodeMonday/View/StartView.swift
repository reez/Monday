//
//  StartView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/17/23.
//

import SwiftUI

class StartViewModel: ObservableObject {
    @Published var networkColor = Color.gray
    @Published var isStarted: Bool = false
    
    func start() async throws {
        try await LightningNodeService.shared.start()
        DispatchQueue.main.async {
            self.isStarted = true
        }
    }
    
    func getColor() {
        let color = LightningNodeService.shared.networkColor
        self.networkColor = color
    }
    
}

struct StartView: View {
    @ObservedObject var viewModel: StartViewModel

    var body: some View {
        
        ZStack {
            Color(uiColor: UIColor.systemBackground)

            VStack {
                if viewModel.isStarted {
                    // How should I best go to TabHomeView when node is started?
                    TabHomeView(viewModel: .init())
                } else {
                    Text("Starting...")
                    ProgressView()
                }
                
            }
            .tint(viewModel.networkColor)
            .onAppear {
                Task {
                    try await viewModel.start()
                    viewModel.getColor()
                }
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
