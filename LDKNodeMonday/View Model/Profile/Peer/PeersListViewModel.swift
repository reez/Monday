//
//  PeersListViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import LDKNode
import SwiftUI

class PeersListViewModel: ObservableObject {
    @Published var networkColor = Color.gray
    @Published var peers: [PeerDetails] = []

    func listPeers() {
        self.peers = LightningNodeService.shared.listPeers()
    }

    func getColor() {
        let color = LightningNodeService.shared.networkColor
        DispatchQueue.main.async {
            self.networkColor = color
        }
    }

}
