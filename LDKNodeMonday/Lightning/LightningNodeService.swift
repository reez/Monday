//
//  LightningNodeService.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/20/23.
//

import Foundation
import LightningDevKitNode

class LightningNodeService {
    private let node: Node
    private let storageManager = LightningStorage()
    
    class var shared: LightningNodeService {
        struct Singleton {
            static let instance = LightningNodeService()
        }
        return Singleton.instance
    }
    
    init() {
        let storageDirectoryPath = storageManager.getDocumentsDirectory()
        let esploraServerUrl = "http://blockstream.info/testnet/api/"
        let network = "testnet"
        let listeningAddress: String? = nil
        let defaultCltvExpiryDelta = UInt32(2048)
        
        let ldkConfig = Config(
            storageDirPath: storageDirectoryPath,
            esploraServerUrl: esploraServerUrl,
            network: network,
            listeningAddress: listeningAddress,
            defaultCltvExpiryDelta: defaultCltvExpiryDelta
        )
        
        let nodeBuilder = Builder.fromConfig(config: ldkConfig)
        let node = nodeBuilder.build()
        self.node = node
    }
    
    func start() async throws {
        do {
            try node.start()
            print("LDKNodeMonday /// Started node!")
        } catch {
            print("LDKNodeMonday /// error starting node: \(error.localizedDescription)")
        }
    }
    
    func getNodeId() -> String? {
        do {
            let nodeID = try node.nodeId()
            print("LDKNodeMonday /// My node ID: \(nodeID)")
            return nodeID
        } catch {
            print("LDKNodeMonday /// error getting nodeID: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getAddress() -> String? {
        do {
            let address = try node.newFundingAddress()
            print("LDKNodeMonday /// Address: \(address)")
            return address
        } catch {
            print("LDKNodeMonday /// error getting address: \(error.localizedDescription)")
            return nil
        }
    }
    
    func openChannel(nodePubkeyAndAddress: String, channelAmountSats: UInt64) {
        do {
            try node.connectOpenChannel(
                nodePubkeyAndAddress: nodePubkeyAndAddress,
                channelAmountSats: channelAmountSats,
                announceChannel: true
            )
            print("LDKNodeMonday /// opened channel to \(nodePubkeyAndAddress) with amount \(channelAmountSats)")
        } catch {
            print("LDKNodeMonday /// error getting openChannel: \(error.localizedDescription)")
        }
    }
    
    func syncWallets() {
        do {
            try node.syncWallets()
        } catch {
            print("LDKNodeMonday /// error syncing wallets: \(error.localizedDescription)")
        }
    }
        
    func getTotalOnchainBalanceSats() -> UInt64? {
        do {
            let balance = try node.totalOnchainBalanceSats()
            print("LDKNodeMonday /// My balance: \(balance)")
            return balance
        } catch {
            print("LDKNodeMonday /// error getting getTotalOnchainBalanceSats: \(error.localizedDescription)")
            return nil
        }
    }
    
}
