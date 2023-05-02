//
//  StopView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/2/23.
//

import SwiftUI
import LightningDevKitNode
import WalletUI

class StopViewModel: ObservableObject {
    
    func stop() {
        LightningNodeService.shared.stop()
    }
    
}

struct StopView: View {
    @ObservedObject var viewModel: StopViewModel
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: UIColor.systemBackground)
                
                VStack {
                    
                    Button("Stop") {
                        viewModel.stop()
                    }
                    .buttonStyle(BitcoinOutlined())
                    
                }
                .padding()
                .navigationTitle("Stop")

            }
            
        }
        
    }
}

struct StopView_Previews: PreviewProvider {
    static var previews: some View {
        StopView(viewModel: .init())
        StopView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
