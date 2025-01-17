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
    let lightningClient: LightningNodeClient

    init(lightningClient: LightningNodeClient) {
        self.lightningClient = lightningClient
    }

    func listPeers() {
        self.peers = lightningClient.listPeers()
    }
}
