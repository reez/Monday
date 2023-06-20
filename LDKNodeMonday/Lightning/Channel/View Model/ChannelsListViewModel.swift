//
//  ChannelsListViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import SwiftUI
import LDKNode

class ChannelsListViewModel: ObservableObject {
    @Published var channels: [ChannelDetails] = []
    @Published var networkColor = Color.gray
    
    func listChannels() {
        self.channels = LightningNodeService.shared.listChannels()
    }
    
    func getColor() {
        let color = LightningNodeService.shared.networkColor
        DispatchQueue.main.async {
            self.networkColor = color
        }
    }
    
}
