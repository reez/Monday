//
//  PeersListViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import LDKNode
import SwiftUI

class PeersListViewModel: ObservableObject {
    @Published var peers: [PeerDetails] = []

    func listPeers() {
        self.peers = LightningNodeService.shared.listPeers()
    }

}
