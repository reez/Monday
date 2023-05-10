//
//  LightningNodeService.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/20/23.
//

import Foundation
import LightningDevKitNode
import SwiftUI

enum BitcoinNetworkColor {
    case regtest
    case signet
    case mainnet
    case testnet
    
    var color: Color {
        switch self {
        case .regtest:
            return Color.green
        case .signet:
            return Color.yellow
        case .mainnet:
            return Color.orange // I'm just going to make it orange instead of black //Color.black
        case .testnet:
            return Color.red
        }
    }
}


class LightningNodeService {
    private let node: Node
    private let storageManager = LightningStorage()
    var ldkNodeMondayEvent = LDKNodeMondayEvent.none
    var networkColor = Color.black
    
    class var shared: LightningNodeService {
        struct Singleton {
            static let instance = LightningNodeService(network: .regtest)
        }
        return Singleton.instance
    }
    
    init(network: NetworkConnection) {
        
        // Delete log file before `start` to keep log file small and loadable in Log View
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let logFilePath = URL(fileURLWithPath: documentsPath).appendingPathComponent("ldk_node.log").path
        do {
            try FileManager.default.removeItem(atPath: logFilePath)
            print("Log file deleted successfully")
        } catch {
            print("Error deleting log file: \(error.localizedDescription)")
        }

        
        let storageDirectoryPath = storageManager.getDocumentsDirectory()
        var esploraServerUrl = "http://blockstream.info/testnet/api/"
        var chosenNetwork = "testnet"
        var listeningAddress: String? = nil
        let defaultCltvExpiryDelta = UInt32(2048)
        
        switch network {
            
        case .regtest:
            chosenNetwork = "regtest"
            esploraServerUrl = "http://ldk-node.tnull.de:3002"//"http://127.0.0.1:3002"
            listeningAddress = "127.0.0.1:2323"
            print("LDKNodeMonday /// Network chosen: \(chosenNetwork)")
            self.networkColor = BitcoinNetworkColor.regtest.color
            
        case .testnet:
            chosenNetwork = "testnet"
            esploraServerUrl = "http://blockstream.info/testnet/api/"
            listeningAddress = "0.0.0.0:9735"
            print("LDKNodeMonday /// Network chosen: \(chosenNetwork)")
            self.networkColor = BitcoinNetworkColor.testnet.color
            
        }
        
        let config = Config(
            storageDirPath: storageDirectoryPath,
            esploraServerUrl: esploraServerUrl,
            network: chosenNetwork,
            listeningAddress: listeningAddress,
            defaultCltvExpiryDelta: defaultCltvExpiryDelta
        )
        print("LDKNodeMonday /// config: \(config)")
        
        let nodeBuilder = Builder.fromConfig(config: config)
        let node = nodeBuilder.build()
        self.node = node
    }
    
    func start() async throws {
        do {
            try node.start()
            print("LDKNodeMonday /// Started node!")
            
        } catch let error as NodeError {
            
            handleNodeError(error)
            
            
        } catch {
            print("LDKNodeMonday /// error starting node: \(error.localizedDescription)")
        }
    }
    
    func stop() {
        
        do {
            
            try node.stop()
            print("LDKNodeMonday /// Stopped node!")
            
        } catch let error as NodeError {
            
            handleNodeError(error)
            
        } catch {
            print("LDKNodeMonday /// error stopping node: \(error.localizedDescription)")
        }
        
    }
    
    func nextEvent() {
        let nextEvent = node.nextEvent() // TODO: return event
        print("LDKNodeMonday /// nextEvent: \n \(nextEvent)")
        
        switch nextEvent {
            
        case .paymentSuccessful(paymentHash: let paymentHash):
            print("LDKNodeMonday /// event: paymentSuccessful \n paymentHash \(paymentHash)")
            let event = convertToLDKNodeMondayEvent(event: .paymentSuccessful(paymentHash: paymentHash))
            self.ldkNodeMondayEvent = event
            
        case .paymentFailed(paymentHash: let paymentHash):
            print("LDKNodeMonday /// event: paymentFailed \n paymentHash \(paymentHash)")
            let event = convertToLDKNodeMondayEvent(event: .paymentFailed(paymentHash: paymentHash))
            self.ldkNodeMondayEvent = event
            
        case .paymentReceived(paymentHash: let paymentHash, amountMsat: let amountMsat):
            print("LDKNodeMonday /// event: paymentReceived \n paymentHash \(paymentHash) \n amountMsat \(amountMsat)")
            let event = convertToLDKNodeMondayEvent(event: .paymentReceived(paymentHash: paymentHash, amountMsat: amountMsat))
            self.ldkNodeMondayEvent = event
            
        case .channelReady(channelId: let channelId, userChannelId: let userChannelId):
            print("LDKNodeMonday /// event: channelReady \n channelId \(channelId) \n userChannelId \(userChannelId)")
            let event = convertToLDKNodeMondayEvent(event: .channelReady(channelId: channelId, userChannelId: userChannelId))
            self.ldkNodeMondayEvent = event
            
        case .channelClosed(channelId: let channelId, userChannelId: let userChannelId):
            print("LDKNodeMonday /// event: channelClosed \n channelId \(channelId) \n userChannelId \(userChannelId)")
            let event = convertToLDKNodeMondayEvent(event: .channelClosed(channelId: channelId, userChannelId: userChannelId))
            self.ldkNodeMondayEvent = event
            
        case .channelPending(channelId: let channelId, userChannelId: let userChannelId, formerTemporaryChannelId: let formerTemporaryChannelId, counterpartyNodeId: let counterpartyNodeId, fundingTxo: let fundingTxo):
            let event = convertToLDKNodeMondayEvent(event: .channelPending(channelId: channelId, userChannelId: userChannelId, formerTemporaryChannelId: formerTemporaryChannelId, counterpartyNodeId: counterpartyNodeId, fundingTxo: fundingTxo))
            self.ldkNodeMondayEvent = event
            
        }
        
    }
    
    func eventHandled() {
        node.eventHandled()
        print("LDKNodeMonday /// eventHandled")
    }
    
    func nodeId() -> String {
        let nodeID = node.nodeId()
        print("LDKNodeMonday /// My node ID: \(nodeID)")
        return nodeID
    }
    
    func newFundingAddress() -> String? {
        do {
            let fundingAddress = try node.newFundingAddress()
            print("LDKNodeMonday /// Funding Address: \(fundingAddress)")
            return fundingAddress
        } catch {
            print("LDKNodeMonday /// error getting funding address: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getSpendableOnchainBalanceSats() async -> UInt64? {
        do {
            let balance = try node.spendableOnchainBalanceSats()
            print("LDKNodeMonday /// My balance: \(balance)")
            return balance
        } catch {
            print("LDKNodeMonday /// error getting getSpendableOnchainBalanceSats: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getTotalOnchainBalanceSats() async -> UInt64? {
        do {
            let balance = try node.totalOnchainBalanceSats()
            print("LDKNodeMonday /// My balance: \(balance)")
            return balance
        } catch {
            print("LDKNodeMonday /// error getting getTotalOnchainBalanceSats: \(error.localizedDescription)")
            return nil
        }
    }
    
    func connect(nodeId: PublicKey, address: SocketAddr, permanently: Bool) {
        print("LDKNodeMonday /// connect")
        do {
            try node.connect(
                nodeId: nodeId,
                address: address,
                permanently: permanently
            )
            print("LDKNodeMonday /// connected to \(nodeId):\(address) (permanently \(permanently))")
        } catch {
            print("LDKNodeMonday /// error on connect: \(error.localizedDescription)")
        }
    }
    
    func disconnect(nodeId: PublicKey) {
        print("LDKNodeMonday /// disconnect")
        do {
            try node.disconnect(nodeId: nodeId)
        } catch {
            print("LDKNodeMonday /// error on disconnect: \(error.localizedDescription)")
        }
    }
    
    func connectOpenChannel(
        nodeId: PublicKey,
        address: SocketAddr,
        channelAmountSats: UInt64,
        pushToCounterpartyMsat: UInt64?,
        announceChannel: Bool = true
    ) {
        do {
            try node.connectOpenChannel(
                nodeId: nodeId,
                address: address,
                channelAmountSats: channelAmountSats,
                pushToCounterpartyMsat: pushToCounterpartyMsat,
                announceChannel: true
            )
            print("LDKNodeMonday /// opened channel to \(nodeId):\(address) with amount \(channelAmountSats)")
        } catch {
            print("LDKNodeMonday /// error getting connectOpenChannel: \(error.localizedDescription)")
        }
    }
    
    func closeChannel(channelId: ChannelId, counterpartyNodeId: PublicKey) {
        print("LDKNodeMonday /// closeChannel")
        do {
            try node.closeChannel(channelId: channelId, counterpartyNodeId: counterpartyNodeId)
        } catch {
            print("LDKNodeMonday /// error on closeChannel: \(error.localizedDescription)")
        }
    }
    
    func sendPayment(invoice: Invoice) async -> PaymentHash? {
        do {
            let paymentHash = try node.sendPayment(invoice: invoice)
            print("LDKNodeMonday /// sendPayment paymentHash: \(paymentHash)")
            return paymentHash
        } catch {
            print("LDKNodeMonday /// sendPayment couldn't equate error to Node Error")
            return nil
        }
    }
    
    func receivePayment(amountMsat: UInt64, description: String, expirySecs: UInt32) async -> Invoice? {
        do {
            let invoice = try node.receivePayment(amountMsat: amountMsat, description: description, expirySecs: expirySecs)
            return invoice
        } catch {
            print("LDKNodeMonday /// receivePayment couldn't equate error to Node Error")
            return nil
        }
    }
    
    func listPeers() -> [PeerDetails] {
        print("LDKNodeMonday /// listPeers")
        let peers = node.listPeers()
        print("LDKNodeMonday /// listPeers peers: \(peers)")
        return peers
    }
    
    func listChannels() -> [ChannelDetails] {
        let channels = node.listChannels()
        print("LDKNodeMonday /// listChannels: \(channels)")
        return channels
    }
    
}

// Currently unused
extension LightningNodeService {
    
    func listeningAddress() -> SocketAddr? {
        guard let address = node.listeningAddress() else { return nil }
        print("LDKNodeMonday /// listeningAddress: \(address)")
        return address
    }
    
    func sendToOnchainAddress(address: Address, amountMsat: UInt64) {
        do {
            let txId = try node.sendToOnchainAddress(address: address, amountMsat: amountMsat)
            print("LDKNodeMonday /// sendToOnchainAddress txId: \(txId)")
        } catch {
            print("LDKNodeMonday /// error on sendToOnchainAddress: \(error.localizedDescription)")
        }
    }
    
    func sendAllToOnchainAddress(address: Address) {
        do {
            let txId = try node.sendAllToOnchainAddress(address: address)
            print("LDKNodeMonday /// sendAllToOnchainAddress txId: \(txId)")
        } catch {
            print("LDKNodeMonday /// error on sendAllToOnchainAddress: \(error.localizedDescription)")
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
    
    func sendPaymentUsingAmount(invoice: Invoice, amountMsat: UInt64) {
        print("LDKNodeMonday /// sendPaymentUsingAmount")
        do {
            let paymentHash = try node.sendPaymentUsingAmount(invoice: invoice, amountMsat: amountMsat)
            print("LDKNodeMonday /// sendPaymentUsingAmount paymentHash: \(paymentHash)")
        } catch {
            print("LDKNodeMonday /// error on sendPaymentUsingAmount: \(error.localizedDescription)")
        }
    }
    
    func sendSpontaneousPayment(amountMsat: UInt64, nodeId: String) {
        do {
            let paymentHash = try node.sendSpontaneousPayment(amountMsat: amountMsat, nodeId: nodeId)
            print("LDKNodeMonday /// sendSpontaneousPayment paymentHash: \(paymentHash)")
        } catch {
            if let mine = error as? NodeError {
                let _ = MondayNodeError(nodeError: mine)
            } else {
                print("LDKNodeMonday /// sendSpontaneousPayment couldn't equate error to Node Error")
            }
        }
    }
    
    func receiveVariableAmountPayment(description: String, expirySecs: UInt32) {
        print("LDKNodeMonday /// receiveVariableAmountPayment")
        do {
            let invoice = try node.receiveVariableAmountPayment(description: description, expirySecs: expirySecs)
            print("LDKNodeMonday /// receiveVariableAmountPayment invoice: \(invoice)")
        } catch {
            print("LDKNodeMonday /// receiveVariableAmountPayment couldn't equate error to Node Error")
        }
    }
    
    func paymentInfo(paymentHash: PaymentHash) {
        print("LDKNodeMonday /// paymentInfo")
        guard let paymentInfo = node.payment(paymentHash: paymentHash) else { return }
        print("LDKNodeMonday /// paymentInfo: \(paymentInfo)")
    }
    
    func removePayment(paymentHash: PaymentHash) {
        do {
            let payment = try node.removePayment(paymentHash: paymentHash)
            print("LDKNodeMonday /// paymentInfo: \(payment)")
        } catch {
            print("LDKNodeMonday /// removePayment couldn't equate error to Node Error")
        }
    }
    
}
