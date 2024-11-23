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

        let storedNetworkString = try! keyService.getNetwork() ?? Network.signet.description
        let storedEsploraURL =
            try! keyService.getEsploraURL()
            ?? EsploraServer.mutiny_signet.url

        self.network = Network(stringValue: storedNetworkString) ?? .signet
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
        nodeBuilder.setChainSourceEsplora(serverUrl: storedEsploraURL, config: nil)

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
                address: Constants.Config.LiquiditySourceLsps2.Signet.lqwd.address,
                nodeId: Constants.Config.LiquiditySourceLsps2.Signet.lqwd.nodeId,
                token: Constants.Config.LiquiditySourceLsps2.Signet.lqwd.token
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
        let nodeId = ldkNode.nodeId()
        return nodeId
    }

    func newAddress() async throws -> String {
        let address = try ldkNode.onchainPayment().newAddress()
        return address
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
        let balances = ldkNode.listBalances().lightningBalances
        return balances
    }

    func pendingBalancesFromChannelClosures() async -> [PendingSweepBalance] {
        let balances = ldkNode.listBalances().pendingBalancesFromChannelClosures
        return balances
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
        let userChannelId = try ldkNode.openChannel(
            nodeId: nodeId,
            address: address,
            channelAmountSats: channelAmountSats,
            pushToCounterpartyMsat: pushToCounterpartyMsat,
            channelConfig: nil
        )
        return userChannelId
    }

    func closeChannel(userChannelId: ChannelId, counterpartyNodeId: PublicKey) throws {
        try ldkNode.closeChannel(
            userChannelId: userChannelId,
            counterpartyNodeId: counterpartyNodeId
        )
    }

    // Parses a URI string, attempts to pay a BOLT12 offer, BOLT11 invoice, then falls back to the on-chain address if the offer and invoice fail.
    func send(uriStr: String) async throws -> QrPaymentResult {
        let qrPaymentResult = try ldkNode.unifiedQrPayment().send(uriStr: uriStr)
        return qrPaymentResult
    }

    // Generates a BIP21 URI string with an on the address and BOLT11 invoice.
    func receive(amountSat: UInt64, message: String, expirySec: UInt32) async throws -> String {
        let bip21UriString = try ldkNode.unifiedQrPayment().receive(
            amountSats: amountSat,
            message: message,
            expirySec: expirySec
        )
        return bip21UriString
    }

    func receiveViaJitChannel(
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
