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
            static let instance = LightningNodeService(network: .testnet)
        }
        return Singleton.instance
    }
    
    init(network: NetworkConnection) {
        
        let storageDirectoryPath = storageManager.getDocumentsDirectory()
        var esploraServerUrl = "http://blockstream.info/testnet/api/"
        var chosenNetwork = "testnet"
        var listeningAddress: String? = nil
        let defaultCltvExpiryDelta = UInt32(2048)
        
        switch network {
        case .regtest:
            chosenNetwork = "regtest"
            esploraServerUrl = "http://127.0.0.1:3002"
            listeningAddress = "127.0.0.1:24224"
            print("LDKNodeMonday /// Network chosen: \(chosenNetwork)")
        case .testnet:
            chosenNetwork = "testnet"
            esploraServerUrl = "http://blockstream.info/testnet/api/"
            print("LDKNodeMonday /// Network chosen: \(chosenNetwork)")
        }
        
        let ldkConfig = Config(
            storageDirPath: storageDirectoryPath,
            esploraServerUrl: esploraServerUrl,
            network: chosenNetwork,
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
