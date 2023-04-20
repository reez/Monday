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
            listeningAddress = "10.0.2.132:3002"
            print("LDKNodeMonday /// Network chosen: \(chosenNetwork)")
        case .testnet:
            chosenNetwork = "testnet"
            esploraServerUrl = "http://blockstream.info/testnet/api/"
            listeningAddress = "127.0.0.1:18333"
            print("LDKNodeMonday /// Network chosen: \(chosenNetwork)")
        }
        
        let ldkConfig = Config(
            storageDirPath: storageDirectoryPath,
            esploraServerUrl: esploraServerUrl,
            network: chosenNetwork,
            listeningAddress: listeningAddress,
            defaultCltvExpiryDelta: defaultCltvExpiryDelta
        )
        print("LDKNodeMonday /// config: \(ldkConfig)")
        
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
    
    func getNodeId() -> String {
        let nodeID = node.nodeId()
        print("LDKNodeMonday /// My node ID: \(nodeID)")
        return nodeID
    }
    
    func getAddress() -> String? {
        do {
            let fundingAddress = try node.newFundingAddress()
            print("LDKNodeMonday /// Funding Address: \(fundingAddress)")
            return fundingAddress
        } catch {
            print("LDKNodeMonday /// error getting funding address: \(error.localizedDescription)")
            return nil
        }
    }

    func openChannel(
        nodeId: PublicKey,
        address: SocketAddr,
        channelAmountSats: UInt64,
        announceChannel: Bool = true
    ) {
        do {
            try node.connectOpenChannel(
                nodeId: nodeId,
                address: address,
                channelAmountSats: channelAmountSats,
                announceChannel: true
            )
            print("LDKNodeMonday /// opened channel to \(nodeId):\(address) with amount \(channelAmountSats)")
        } catch {
            print("LDKNodeMonday /// error getting openChannel: \(error.localizedDescription)")
        }
    }
    
    func syncWallets() {
        do {
            try node.syncWallets()
            print("LDKNodeMonday /// Wallet synced!")
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
    
    func getSpendableOnchainBalanceSats() -> UInt64? {
        do {
            let balance = try node.spendableOnchainBalanceSats()
            print("LDKNodeMonday /// My balance: \(balance)")
            return balance
        } catch {
            print("LDKNodeMonday /// error getting getSpendableOnchainBalanceSats: \(error.localizedDescription)")
            return nil
        }
    }
    
    func nextEvent() {
        let nextEvent = node.nextEvent()
        switch nextEvent {
        case .paymentSuccessful(paymentHash: let paymentHash):
            print("LDKNodeMonday /// event: paymentSuccessful \n paymentHash \(paymentHash)")
        case .paymentFailed(paymentHash: let paymentHash):
            print("LDKNodeMonday /// event: paymentFailed \n paymentHash \(paymentHash)")
        case .paymentReceived(paymentHash: let paymentHash, amountMsat: let amountMsat):
            print("LDKNodeMonday /// event: paymentReceived \n paymentHash \(paymentHash) \n amountMsat \(amountMsat)")
        case .channelReady(channelId: let channelId, userChannelId: let userChannelId):
            print("LDKNodeMonday /// event: channelReady \n channelId \(channelId) \n userChannelId \(userChannelId)")
        case .channelClosed(channelId: let channelId, userChannelId: let userChannelId):
            print("LDKNodeMonday /// event: channelClosed \n channelId \(channelId) \n userChannelId \(userChannelId)")
        }
    }
    
    func eventHandled() {
        node.eventHandled()
    }
    
    func sendSpontaneousPayment(amountMsat: UInt64, nodeId: String) {
        do {
            let paymentHash = try node.sendSpontaneousPayment(amountMsat: amountMsat, nodeId: nodeId)
            print("paymentHash: \(paymentHash)")
        } catch {
            if let mine = error as? NodeError {
                let _ = MondayNodeError(nodeError: mine)
            } else {
                print("couldn't equate error to Node Error")
            }
        }
    }
    
    func sendPayment(invoice: Invoice) {
        do {
            let paymentHash = try node.sendPayment(invoice: invoice)
            print("paymentHash: \(paymentHash)")
        } catch {
            if let mine = error as? NodeError {
                let _ = MondayNodeError(nodeError: mine)
            } else {
                print("couldn't equate error to Node Error")
            }
        }
        
    }
    
}
