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
    @Published var networkColor = Color.gray

    func start() async throws {
        try await LightningNodeService.shared.start()
    }
    
    func getColor() {
        let color = LightningNodeService.shared.networkColor
        self.networkColor = color
        print("got colors")
    }
    
}

struct TabHomeView: View {
    @ObservedObject var viewModel: TabHomeViewModel
    
    var body: some View {
        
        ZStack {
            Color(uiColor: UIColor.systemBackground)
            
            TabView {
                
//                OldAddressView(viewModel: .init())
//                    .tabItem {
//                        Label(
//                            "Old Address",
//                            systemImage: "bitcoinsign"
//                        )
//                    }
//
//                OldBalanceView(viewModel: .init())
//                    .tabItem {
//                        Label(
//                            "Old Balance",
//                            systemImage: "bitcoinsign"
//                        )
//                    }
                
                AddressView(viewModel: .init())
                    .tabItem {
                        Label(
                            "Address",
                            systemImage: "bitcoinsign"
                        )
                    }
                
                ChannelsListView(viewModel: .init())
                    .tabItem {
                        Label(
                            "Channel",
                            systemImage: "person.line.dotted.person"
                        )
                    }
                
                SendView(viewModel: .init())
                    .tabItem {
                        Label(
                            "Send",
                            systemImage: "arrow.up"
                        )
                    }
                
                ReceiveView(viewModel: .init())
                    .tabItem {
                        Label(
                            "Receive",
                            systemImage: "arrow.down"
                        )
                    }
                
//                EventsView(viewModel: .init())
//                    .tabItem {
//                        Label(
//                            "Events",
//                            systemImage: "infinity"
//                        )
//                    }
                
//                PeersListView(viewModel: .init())
//                    .tabItem {
//                        Label(
//                            "Peers",
//                            systemImage: "person.line.dotted.person"
//                        )
//                    }
                
                NodeIDView(viewModel: .init())
                    .tabItem {
                        Label(
                            "Node ID",
                            systemImage: "person"
                        )
                    }
                
//                StopView(viewModel: .init())
//                    .tabItem {
//                        Label(
//                            "Stop",
//                            systemImage: "xmark"
//                        )
//                    }
                
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
    
}

struct TabHomeView_Previews: PreviewProvider {
    static var previews: some View {
        TabHomeView(viewModel: .init())
        TabHomeView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
