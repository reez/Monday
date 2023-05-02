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
                            systemImage: "arrow.down"
                        )
                    }
                
                BalanceView(viewModel: .init())
                    .tabItem {
                        Label(
                            "Balance",
                            systemImage: "line.3.horizontal"
                        )
                    }
                
                ChannelsListView(viewModel: .init())
                    .tabItem {
                        Label(
                            "Channel",
                            systemImage: "plus"
                        )
                    }
                
                SendView(viewModel: .init())
                    .tabItem {
                        Label(
                            "Send",
                            systemImage: "arrow.up"
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
