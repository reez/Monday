//
//  TabHomeView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/21/23.
//

import SwiftUI
import LightningDevKitNode
import WalletUI

struct TabHomeView: View {
    @StateObject var viewModel: TabHomeViewModel
    
    var body: some View {
        
        ZStack {
            Color(uiColor: UIColor.systemBackground)
            
            TabView {
                
                BitcoinView(viewModel: .init())
                    .tabItem {
                        Label(
                            "",
                            systemImage: "bitcoinsign"
                        )
                    }
                
                LightningView(viewModel: .init())
                    .tabItem {
                        Label(
                            "",
                            systemImage: "bolt.fill"
                        )
                    }
                
                NodeIDView(viewModel: .init())
                    .tabItem {
                        Label(
                            "",
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
