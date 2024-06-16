//
//  LightningNodeService.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/20/23.
//

import Foundation
import LDKNode
import SwiftUI
import os

class LightningNodeService {
    static var shared: LightningNodeService = LightningNodeService()
    private let ldkNode: Node
    private let keyService: KeyClient
    var networkColor = Color.black
    var network: Network

    init(
        keyService: KeyClient = .live
    ) {

        let storedNetworkString = try! keyService.getNetwork() ?? Network.testnet.description
        let storedEsploraURL =
            try! keyService.getEsploraURL()
            ?? Constants.Config.EsploraServerURLNetwork.Testnet.mempoolspace

        self.network = Network(stringValue: storedNetworkString) ?? .testnet
        self.keyService = keyService

        var config = defaultConfig()
        config.storageDirPath = FileManager.default.getDocumentsDirectoryPath()
        config.logDirPath = FileManager.default.getDocumentsDirectoryPath()
        config.network = self.network
        config.trustedPeers0conf = [
            Constants.Config.LiquiditySourceLsps2.Signet.mutiny.nodeId
        ]
        config.logLevel = .trace

        let nodeBuilder = Builder.fromConfig(config: config)
        nodeBuilder.setEsploraServer(esploraServerUrl: storedEsploraURL)

        switch self.network {
        case .bitcoin:
            nodeBuilder.setGossipSourceRgs(
                rgsServerUrl: Constants.Config.RGSServerURLNetwork.bitcoin
            )
            self.networkColor = Constants.BitcoinNetworkColor.bitcoin.color
        case .testnet:
            nodeBuilder.setGossipSourceRgs(
                rgsServerUrl: Constants.Config.RGSServerURLNetwork.testnet
            )
            self.networkColor = Constants.BitcoinNetworkColor.testnet.color
        case .signet:
            nodeBuilder.setLiquiditySourceLsps2(
                address: Constants.Config.LiquiditySourceLsps2.Signet.mutiny.address,
                nodeId: Constants.Config.LiquiditySourceLsps2.Signet.mutiny.nodeId,
                token: Constants.Config.LiquiditySourceLsps2.Signet.mutiny.token
            )
            self.networkColor = Constants.BitcoinNetworkColor.signet.color
        case .regtest:
            self.networkColor = Constants.BitcoinNetworkColor.regtest.color
        }

        let mnemonic: String
        do {
            let backupInfo = try keyService.getBackupInfo()
            if backupInfo.mnemonic == "" {
                let newMnemonic = generateEntropyMnemonic()
                let backupInfo = BackupInfo(mnemonic: newMnemonic)
                try? keyService.saveBackupInfo(backupInfo)
                mnemonic = newMnemonic
            } else {
                mnemonic = backupInfo.mnemonic
            }
        } catch {
            let newMnemonic = generateEntropyMnemonic()
            let backupInfo = BackupInfo(mnemonic: newMnemonic)
            try? keyService.saveBackupInfo(backupInfo)
            mnemonic = newMnemonic
        }
        nodeBuilder.setEntropyBip39Mnemonic(mnemonic: mnemonic, passphrase: nil)

        let ldkNode = try! nodeBuilder.build()  // Handle error instead of "!"
        self.ldkNode = ldkNode
    }

    func start() async throws {
        try ldkNode.start()
    }

    func stop() throws {
        try ldkNode.stop()
    }

    func nodeId() -> String {
        let nodeID = ldkNode.nodeId()
        return nodeID
    }

    func newOnchainAddress() async throws -> String {
        let fundingAddress = try ldkNode.onchainPayment().newAddress()
        return fundingAddress
    }

    func spendableOnchainBalanceSats() async -> UInt64 {
        let balance = ldkNode.listBalances().spendableOnchainBalanceSats
        return balance
    }

    func totalOnchainBalanceSats() async -> UInt64 {
        let balance = ldkNode.listBalances().totalOnchainBalanceSats
        return balance
    }

    func totalLightningBalanceSats() async -> UInt64 {
        let balance = ldkNode.listBalances().totalLightningBalanceSats
        return balance
    }

    func lightningBalances() async -> [LightningBalance] {
        let balance = ldkNode.listBalances().lightningBalances
        return balance
    }

    func pendingBalancesFromChannelClosures() async -> [PendingSweepBalance] {
        let balance = ldkNode.listBalances().pendingBalancesFromChannelClosures
        return balance
    }

    func connect(nodeId: PublicKey, address: String, persist: Bool) async throws {
        try ldkNode.connect(
            nodeId: nodeId,
            address: address,
            persist: persist
        )
    }

    func disconnect(nodeId: PublicKey) throws {
        try ldkNode.disconnect(nodeId: nodeId)
    }

    func connectOpenChannel(
        nodeId: PublicKey,
        address: String,
        channelAmountSats: UInt64,
        pushToCounterpartyMsat: UInt64?,
        channelConfig: ChannelConfig?,
        announceChannel: Bool = false
    ) async throws -> UserChannelId {
        let userChannelId = try ldkNode.connectOpenChannel(
            nodeId: nodeId,
            address: address,
            channelAmountSats: channelAmountSats,
            pushToCounterpartyMsat: pushToCounterpartyMsat,
            channelConfig: nil,
            announceChannel: false
        )
        return userChannelId
    }

    func closeChannel(userChannelId: ChannelId, counterpartyNodeId: PublicKey) throws {
        try ldkNode.closeChannel(
            userChannelId: userChannelId,
            counterpartyNodeId: counterpartyNodeId
        )
    }

    /// Send - Bolt 11

    func sendPayment(invoice: Bolt11Invoice) async throws -> PaymentHash {
        let paymentHash = try ldkNode.bolt11Payment().send(invoice: invoice)
        return paymentHash
    }

    func sendPaymentUsingAmount(invoice: Bolt11Invoice, amountMsat: UInt64) async throws
        -> PaymentHash
    {
        let paymentHash = try ldkNode.bolt11Payment().sendUsingAmount(
            invoice: invoice,
            amountMsat: amountMsat
        )
        return paymentHash
    }

    /// Send - Bolt 12

    func sendPaymentBolt12(invoice: Bolt12Invoice) async throws -> PaymentId {
        let payerNote = "BOLT 12 payment payer note"
        let paymentId = try ldkNode.bolt12Payment().send(offer: invoice, payerNote: payerNote)
        return paymentId
    }

    func sendPaymentUsingAmountBolt12(invoice: Bolt12Invoice, amountMsat: UInt64) async throws
        -> PaymentId
    {
        let payerNote = "BOLT 12 payment payer note"
        let paymentId = try ldkNode.bolt12Payment().sendUsingAmount(
            offer: invoice,
            payerNote: payerNote,
            amountMsat: amountMsat
        )
        return paymentId
    }

    /// Receive - Bolt 11

    func receivePayment(amountMsat: UInt64, description: String, expirySecs: UInt32) async throws
        -> Bolt11Invoice
    {
        let invoice = try ldkNode.bolt11Payment().receive(
            amountMsat: amountMsat,
            description: description,
            expirySecs: expirySecs
        )
        return invoice
    }

    func receiveVariableAmountPayment(description: String, expirySecs: UInt32) async throws
        -> Bolt11Invoice
    {
        let invoice = try ldkNode.bolt11Payment().receiveVariableAmount(
            description: description,
            expirySecs: expirySecs
        )
        return invoice
    }

    /// Receive - Bolt 12

    // name these like receive(with amountMSat: ...)
    func receivePaymentBolt12(amountMsat: UInt64, description: String) async throws -> Bolt12Invoice
    {
        let offer = try ldkNode.bolt12Payment().receive(
            amountMsat: amountMsat,
            description: description
        )
        return offer
    }

    func receiveVariableAmountBolt12(description: String) async throws -> Bolt12Invoice {
        let offer = try ldkNode.bolt12Payment().receiveVariableAmount(description: description)
        return offer
    }

    /// Receive - JIT

    func receivePaymentViaJitChannel(
        amountMsat: UInt64,
        description: String,
        expirySecs: UInt32,
        maxLspFeeLimitMsat: UInt64?
    ) async throws -> Bolt11Invoice {
        let invoice = try ldkNode.bolt11Payment().receiveViaJitChannel(
            amountMsat: amountMsat,
            description: description,
            expirySecs: expirySecs,
            maxLspFeeLimitMsat: maxLspFeeLimitMsat
        )
        return invoice
    }

    func listPeers() -> [PeerDetails] {
        let peers = ldkNode.listPeers()
        return peers
    }

    func listChannels() -> [ChannelDetails] {
        let channels = ldkNode.listChannels()
        return channels
    }

    func sendToOnchainAddress(address: Address, amountMsat: UInt64) async throws -> Txid {
        let txId = try ldkNode.onchainPayment().sendToAddress(
            address: address,
            amountMsat: amountMsat
        )
        return txId
    }

    func listPayments() -> [PaymentDetails] {
        let payments = ldkNode.listPayments()
        return payments
    }

    func status() -> NodeStatus {
        let status = ldkNode.status()
        return status
    }

}

extension LightningNodeService {
    func deleteWallet() throws {
        try keyService.deleteBackupInfo()
    }
    func getBackupInfo() throws -> BackupInfo {
        let backupInfo = try keyService.getBackupInfo()
        return backupInfo
    }
}

extension LightningNodeService {
    func listenForEvents() {
        Task {
            while true {
                let event = await ldkNode.nextEventAsync()
                NotificationCenter.default.post(
                    name: .ldkEventReceived,
                    object: event.description
                )
                ldkNode.eventHandled()
            }
        }
    }
}

extension LightningNodeService {
    func save(mnemonic: Mnemonic) throws {
        let backupInfo = BackupInfo(mnemonic: mnemonic)
        try keyService.saveBackupInfo(backupInfo)
    }
}

extension LightningNodeService {
    func deleteDocuments() throws {
        try FileManager.default.deleteAllContentsInDocumentsDirectory()
    }
}
