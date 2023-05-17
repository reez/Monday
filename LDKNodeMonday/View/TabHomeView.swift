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
    
    func getColor() {
        let color = LightningNodeService.shared.networkColor
        DispatchQueue.main.async {
            self.networkColor = color
        }
    }
    
}

struct TabHomeView: View {
    @StateObject var viewModel: TabHomeViewModel
    
    var body: some View {
        
        ZStack {
            Color(uiColor: UIColor.systemBackground)
            
            TabView {
                
                BalanceView(viewModel: .init())
                    .tabItem {
                        Label(
                            "Bitcoin",
                            systemImage: "bitcoinsign"
                        )
                    }
                
                ChannelsListView(viewModel: .init())
                    .tabItem {
                        Label(
                            "Lightning",
                            systemImage: "bolt.fill"
                        )
                    }
                
                NodeIDView(viewModel: .init())
                    .tabItem {
                        Label(
                            "Node",
                            systemImage: "person"
                        )
                    }
                
            }
            .tint(viewModel.networkColor)
            .onAppear {
                Task {
                    viewModel.getColor()
                }
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
