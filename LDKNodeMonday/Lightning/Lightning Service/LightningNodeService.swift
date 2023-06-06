//
//  LightningNodeService.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/20/23.
//

import Foundation
import LightningDevKitNode
import SwiftUI

class LightningNodeService {
    private let node: LdkNode
    private let storageManager = LightningStorage()
    var networkColor = Color.black
    
    class var shared: LightningNodeService {
        struct Singleton {
            static let instance = LightningNodeService(network: .regtest)
        }
        return Singleton.instance
    }
    
    init(network: Network) {
        
        try? FileManager.deleteLDKNodeLogFile()
        
        let nodeBuilder = Builder()
        
        switch network {
            
        case .regtest:
            nodeBuilder.setNetwork(network: .regtest)
            nodeBuilder.setEsploraServer(esploraServerUrl: Constants.Config.EsploraServerURLNetwork.regtest)
            nodeBuilder.setStorageDirPath(storageDirPath: storageManager.getDocumentsDirectory())
            self.networkColor = Constants.BitcoinNetworkColor.regtest.color
            
        case .signet:
            nodeBuilder.setNetwork(network: .signet)
            nodeBuilder.setEsploraServer(esploraServerUrl: Constants.Config.EsploraServerURLNetwork.signet)
            nodeBuilder.setStorageDirPath(storageDirPath: storageManager.getDocumentsDirectory())
            self.networkColor = Constants.BitcoinNetworkColor.signet.color
            
        case .testnet:
            nodeBuilder.setNetwork(network: .testnet)
            nodeBuilder.setEsploraServer(esploraServerUrl: Constants.Config.EsploraServerURLNetwork.testnet)
            nodeBuilder.setStorageDirPath(storageDirPath: storageManager.getDocumentsDirectory())
            self.networkColor = Constants.BitcoinNetworkColor.testnet.color
            
        case .bitcoin:
            nodeBuilder.setGossipSourceRgs(rgsServerUrl: "https://rapidsync.lightningdevkit.org/snapshot/")
            self.networkColor = .orange
            
        }
        
        let node = nodeBuilder.build()
        
        self.node = node
    }
    
    func start() async throws {
        try node.start()
    }
    
    func stop() throws {
        try node.stop()
    }
    
    func nodeId() -> String {
        let nodeID = node.nodeId()
        return nodeID
    }
    
    func newFundingAddress() async throws -> String {
        let fundingAddress = try node.newFundingAddress()
        return fundingAddress
    }
    
    func getSpendableOnchainBalanceSats() async throws -> UInt64 {
        let balance = try node.spendableOnchainBalanceSats()
        return balance
    }
    
    func getTotalOnchainBalanceSats() async throws -> UInt64 {
        let balance = try node.totalOnchainBalanceSats()
        return balance
    }
    
    func connect(nodeId: PublicKey, address: String, permanently: Bool) async throws {
        try node.connect(
            nodeId: nodeId,
            address: address,
            permanently: permanently
        )
    }
    
    func disconnect(nodeId: PublicKey) throws {
        try node.disconnect(nodeId: nodeId)
    }
    
    func connectOpenChannel(
        nodeId: PublicKey,
        address: String,
        channelAmountSats: UInt64,
        pushToCounterpartyMsat: UInt64?,
        announceChannel: Bool = true
    ) async throws {
        try node.connectOpenChannel(
            nodeId: nodeId,
            address: address,
            channelAmountSats: channelAmountSats,
            pushToCounterpartyMsat: pushToCounterpartyMsat,
            announceChannel: true
        )
    }
    
    func closeChannel(channelId: ChannelId, counterpartyNodeId: PublicKey) throws {
        try node.closeChannel(channelId: channelId, counterpartyNodeId: counterpartyNodeId)
    }
    
    func sendPayment(invoice: Invoice) async throws -> PaymentHash {
        let paymentHash = try node.sendPayment(invoice: invoice)
        return paymentHash
    }
    
    func receivePayment(amountMsat: UInt64, description: String, expirySecs: UInt32) async throws -> Invoice {
        let invoice = try node.receivePayment(amountMsat: amountMsat, description: description, expirySecs: expirySecs)
        return invoice
    }
    
    func listPeers() -> [PeerDetails] {
        let peers = node.listPeers()
        return peers
    }
    
    func listChannels() -> [ChannelDetails] {
        let channels = node.listChannels()
        return channels
    }
    
}

// Currently unused
extension LightningNodeService {
    
    func nextEvent() {
        let _ = node.nextEvent()
    }
    
    func eventHandled() {
        node.eventHandled()
    }
    
    func listeningAddress() -> String? {
        guard let address = node.listeningAddress() else { return nil }
        return address
    }
    
    func sendToOnchainAddress(address: Address, amountMsat: UInt64) throws -> Txid {
        let txId = try node.sendToOnchainAddress(address: address, amountMsat: amountMsat)
        return txId
    }
    
    func sendAllToOnchainAddress(address: Address) throws -> Txid {
        let txId = try node.sendAllToOnchainAddress(address: address)
        return txId
    }
    
    func syncWallets() throws {
        try node.syncWallets()
    }
    
    func sendPaymentUsingAmount(invoice: Invoice, amountMsat: UInt64) throws -> PaymentHash {
        let paymentHash = try node.sendPaymentUsingAmount(invoice: invoice, amountMsat: amountMsat)
        return paymentHash
    }
    
    func sendSpontaneousPayment(amountMsat: UInt64, nodeId: String) throws -> PaymentHash {
        let paymentHash = try node.sendSpontaneousPayment(amountMsat: amountMsat, nodeId: nodeId)
        return paymentHash
    }
    
    func receiveVariableAmountPayment(description: String, expirySecs: UInt32) throws -> Invoice {
        let invoice = try node.receiveVariableAmountPayment(description: description, expirySecs: expirySecs)
        return invoice
    }
    
    func paymentInfo(paymentHash: PaymentHash) -> PaymentDetails? {
        guard let paymentDetails = node.payment(paymentHash: paymentHash) else { return nil }
        return paymentDetails
    }
    
    func removePayment(paymentHash: PaymentHash) throws -> Bool {
        let payment = try node.removePayment(paymentHash: paymentHash)
        return payment
    }
    
}
