//
//  TabHomeView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/21/23.
//

import SwiftUI

import LightningDevKitNode
import WalletUI

class TabHomeViewModel: ObservableObject {
    
    func start() async throws {
        try await LightningNodeService.shared.start()
    }
    
}

struct TabHomeView: View {
    @ObservedObject var viewModel: TabHomeViewModel

    var body: some View {
        
        ZStack {
            Color(uiColor: UIColor.systemBackground)
            
            TabView {
                
                AddressView(viewModel: .init())
                    .tabItem {
                        Label(
                            "Address",
                            systemImage: "bitcoinsign"
                        )
                    }
                
                BalanceView(viewModel: .init())
                    .tabItem {
                        Label(
                            "Balance",
                            systemImage: "wallet.pass"
                        )
                    }
                
                ChannelView(viewModel: .init())
                    .tabItem {
                        Label(
                            "Channel",
                            systemImage: "fibrechannel"
                        )
                    }
                
                NodeIDView(viewModel: .init())
                    .tabItem {
                        Label(
                            "Node ID",
                            systemImage: "person"
                        )
                    }
                
            }
            
        }
        .onAppear {
            Task {
                try await viewModel.start()
            }
        }
        
    }
    
}

struct TabHomeView_Previews: PreviewProvider {
    static var previews: some View {
        TabHomeView(viewModel: .init())
        TabHomeView(viewModel: .init())
            .environment(\.colorScheme, .dark)
        
    }
}
