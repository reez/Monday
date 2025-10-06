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
    private static let lock = NSLock()
    private static var _shared: LightningNodeService?
    static var shared: LightningNodeService {
        get {
            lock.lock()
            defer { lock.unlock() }
            if _shared == nil {
                _shared = LightningNodeService()
            }
            return _shared!
        }
        set {
            lock.lock()
            _shared = newValue
            lock.unlock()
        }
    }
    private let ldkNode: Node
    private let keyService: KeyClient
    var networkColor = Color.black
    var network: Network
    var server: EsploraServer
    var lsp: LightningServiceProvider
    private var eventListenerTask: Task<Void, Never>?

    deinit {
        cancelEventListenerTask()
    }

    init(
        keyService: KeyClient = .live
    ) {

        if let backupInfo = try? KeyClient.live.getBackupInfo() {
            guard let network = Network(stringValue: backupInfo.networkString) else {
                // This should never happen, but if it does:
                fatalError("Configuration error: No Network found in BackupInfo")
            }
            self.network = network

            guard
                let server =
                    EsploraServer(URLString: backupInfo.serverURL)
                    ?? availableServers(network: network).first
            else {
                // This should never happen, but if it does:
                fatalError("Configuration error: No Esplora servers available for \(network)")
            }
            self.server = server
            self.lsp =
                LightningServiceProvider.getByNodeId(
                    backupInfo.lspNodeId ?? LightningServiceProvider.see_signet.nodeId
                ) ?? .see_signet
        } else {
            self.network = .signet
            self.server = .mutiny_signet
            self.lsp = .see_signet
        }

        self.keyService = keyService

        let documentsPath = FileManager.default.getDocumentsDirectoryPath()
        let networkPath = URL(fileURLWithPath: documentsPath)
            .appendingPathComponent(network.description)
            .path
        let logPath = networkPath + "/logs"

        try? FileManager.default.createDirectory(
            atPath: logPath,
            withIntermediateDirectories: true
        )

        // This is what `Config` looks like now, need to find out where `logDirPath` and `logLevel` are now

        //        public struct Config {
        //            public var storageDirPath: String
        //            public var network: Network
        //            public var listeningAddresses: [SocketAddress]?
        //            public var nodeAlias: NodeAlias?
        //            public var trustedPeers0conf: [PublicKey]
        //            public var probingLiquidityLimitMultiplier: UInt64
        //            public var anchorChannelsConfig: AnchorChannelsConfig?
        //            public var sendingParameters: SendingParameters?

        var config = defaultConfig()
        config.storageDirPath = networkPath
        //        config.logDirPath = logPath
        config.network = self.network
        config.trustedPeers0conf = [self.lsp.nodeId]
        //        config.logLevel = .trace

        // Faster sync intervals for better balance updates (moved under EsploraSyncConfig)
        let backgroundSync = BackgroundSyncConfig(
            onchainWalletSyncIntervalSecs: 20,  // Default: 80 seconds
            lightningWalletSyncIntervalSecs: 10,  // Default: 30 seconds
            feeRateCacheUpdateIntervalSecs: 600  // Default: 600 seconds
        )

        let anchor_cfg = AnchorChannelsConfig(
            trustedPeersNoReserve: [self.lsp.nodeId],
            perChannelReserveSats: UInt64(0)
        )
        config.anchorChannelsConfig = .some(anchor_cfg)

        let nodeBuilder = Builder.fromConfig(config: config)
        // Enable filesystem logging
        let logFilePath = logPath + "/ldk-node.log"
        nodeBuilder.setFilesystemLogger(logFilePath: logFilePath, maxLogLevel: .trace)
        let esploraSyncConfig = EsploraSyncConfig(backgroundSyncConfig: .some(backgroundSync))
        nodeBuilder.setChainSourceEsplora(serverUrl: self.server.url, config: esploraSyncConfig)

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
            nodeBuilder.setGossipSourceRgs(
                rgsServerUrl: Constants.Config.RGSServerURLNetwork.signet
            )
            nodeBuilder.setLiquiditySourceLsps2(
                nodeId: lsp.nodeId,
                address: lsp.address,
                token: lsp.token
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
                let backupInfo = BackupInfo(
                    mnemonic: newMnemonic,
                    networkString: self.network.description,
                    serverURL: self.server.url
                )
                try? keyService.saveBackupInfo(backupInfo)
                mnemonic = newMnemonic
            } else {
                mnemonic = backupInfo.mnemonic
            }
        } catch {
            let newMnemonic = generateEntropyMnemonic()
            let backupInfo = BackupInfo(
                mnemonic: newMnemonic,
                networkString: self.network.description,
                serverURL: self.server.url
            )
            try? keyService.saveBackupInfo(backupInfo)
            mnemonic = newMnemonic
        }
        nodeBuilder.setEntropyBip39Mnemonic(mnemonic: mnemonic, passphrase: nil)

        do {
            let ldkNode = try nodeBuilder.build()
            self.ldkNode = ldkNode
        } catch {
            print("Failed to build node, attempting recovery: \(error)")
            // If wallet setup fails, clean up and try once more
            if case BuildError.WalletSetupFailed = error {
                print("Cleaning up corrupted wallet data...")
                try? FileManager.default.removeItem(atPath: networkPath)

                // Recreate the directories
                try? FileManager.default.createDirectory(
                    atPath: logPath,
                    withIntermediateDirectories: true
                )

                // Try building again with clean state
                let ldkNode = try! nodeBuilder.build()
                self.ldkNode = ldkNode
            } else {
                // For other errors, fail as before
                fatalError("Unexpected error building node: \(error)")
            }
        }
    }

    private static func existingInstance() -> LightningNodeService? {
        lock.lock()
        let instance = _shared
        lock.unlock()
        return instance
    }

    static func stopAndReleaseShared() throws {
        guard let instance = existingInstance() else { return }
        do {
            try instance.stop()
        } catch let error as NodeError {
            if case .NotRunning = error {
                instance.cancelEventListenerTask()
            } else {
                throw error
            }
        }
        stopTrackingSharedInstance()
    }

    static func rebuildShared(keyService: KeyClient) throws -> LightningNodeService {
        if let instance = existingInstance() {
            do {
                try instance.stop()
            } catch let error as NodeError {
                if case .NotRunning = error {
                    instance.cancelEventListenerTask()
                } else {
                    throw error
                }
            }
        }

        let service = LightningNodeService(keyService: keyService)
        lock.lock()
        _shared = service
        lock.unlock()
        return service
    }

    private static func stopTrackingSharedInstance() {
        lock.lock()
        _shared = nil
        lock.unlock()
    }

    func start() async throws {
        try ldkNode.start()
    }

    func stop() throws {
        cancelEventListenerTask()
        try ldkNode.stop()
    }

    func restart() async throws {
        if self.status().isRunning {
            try self.stop()
        }
        try await self.start()
    }

    func reset() throws {
        if let instance = LightningNodeService.existingInstance() {
            if instance.status().isRunning {
                try instance.stop()
            }
            instance.cancelEventListenerTask()
        }

        // Clean up wallet data to prevent conflicts on next initialization
        let documentsPath = FileManager.default.getDocumentsDirectoryPath()
        let networkPath = URL(fileURLWithPath: documentsPath)
            .appendingPathComponent(network.description)
            .path

        try? FileManager.default.removeItem(atPath: networkPath)

        LightningNodeService.stopTrackingSharedInstance()
    }

    func nodeId() -> String {
        let nodeId = ldkNode.nodeId()
        return nodeId
    }

    func newAddress() async throws -> String {
        let address = try ldkNode.onchainPayment().newAddress()
        return address
    }

    func listBalances() async -> BalanceDetails {
        let balances = ldkNode.listBalances()
        return balances
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

    // Pays a Bolt11 invoice
    func sendBolt11Payment(invoice: Bolt11Invoice, sendingParameters: SendingParameters?)
        async throws
        -> PaymentId
    {
        let bolt11Payment = try ldkNode.bolt11Payment().send(
            invoice: invoice,
            sendingParameters: sendingParameters
        )
        return bolt11Payment
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

    func bolt11Payment(
        amountMsat: UInt64,
        description: Bolt11InvoiceDescription,
        expirySecs: UInt32,
        maxLspFeeLimitMsat: UInt64?,
        receiveViaJitChannel: Bool?
    ) async throws -> Bolt11Invoice {
        if receiveViaJitChannel ?? false {
            let invoice = try ldkNode.bolt11Payment().receiveViaJitChannel(
                amountMsat: amountMsat,
                description: description,
                expirySecs: expirySecs,
                maxLspFeeLimitMsat: maxLspFeeLimitMsat
            )
            return invoice
        } else {
            let invoice = try ldkNode.bolt11Payment().receive(
                amountMsat: amountMsat,
                description: description,
                expirySecs: expirySecs
            )
            return invoice
        }
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
        eventListenerTask?.cancel()
        eventListenerTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                let event = await self.ldkNode.nextEventAsync()
                if Task.isCancelled { break }
                NotificationCenter.default.post(
                    name: .ldkEventReceived,
                    object: event
                )
                try? self.ldkNode.eventHandled()
            }
        }
    }

    func syncWallets() throws {
        try self.ldkNode.syncWallets()
    }
}

extension LightningNodeService {
    fileprivate func cancelEventListenerTask() {
        eventListenerTask?.cancel()
        eventListenerTask = nil
    }
}

extension LightningNodeService {
    func save(mnemonic: Mnemonic) throws {
        let backupInfo = BackupInfo(
            mnemonic: mnemonic,
            networkString: self.network.description,
            serverURL: self.server.url
        )
        try keyService.saveBackupInfo(backupInfo)
    }
}

extension LightningNodeService {
    func deleteDocuments() throws {
        try FileManager.default.deleteAllContentsInDocumentsDirectory()
    }
}

public struct LightningNodeClient {
    let start: () async throws -> Void
    let stop: () throws -> Void
    let restart: () async throws -> Void
    let reset: () throws -> Void
    let nodeId: () -> String
    let newAddress: () async throws -> String
    let balances: () async -> BalanceDetails
    let spendableOnchainBalanceSats: () async -> UInt64
    let totalOnchainBalanceSats: () async -> UInt64
    let totalLightningBalanceSats: () async -> UInt64
    let lightningBalances: () async -> [LightningBalance]
    let pendingBalancesFromChannelClosures: () async -> [PendingSweepBalance]
    let connect: (PublicKey, String, Bool) async throws -> Void
    let disconnect: (PublicKey) throws -> Void
    let connectOpenChannel:
        (PublicKey, String, UInt64, UInt64?, ChannelConfig?, Bool) async throws -> UserChannelId
    let closeChannel: (ChannelId, PublicKey) throws -> Void
    let send: (String) async throws -> QrPaymentResult
    let sendBolt11Payment: (Bolt11Invoice, SendingParameters?) async throws -> PaymentId
    let receive: (UInt64, String, UInt32) async throws -> String
    let bolt11Payment:
        (UInt64, Bolt11InvoiceDescription, UInt32, UInt64?, Bool?) async throws -> Bolt11Invoice
    let listPeers: () -> [PeerDetails]
    let listChannels: () -> [ChannelDetails]
    let listPayments: () -> [PaymentDetails]
    let status: () -> NodeStatus
    let deleteWallet: () throws -> Void
    let getBackupInfo: () throws -> BackupInfo
    let deleteDocuments: () throws -> Void
    let getNetwork: () -> Network
    let getServer: () -> EsploraServer
    let getNetworkColor: () -> Color
    let listenForEvents: () -> Void
    let syncWallets: () throws -> Void
}

extension LightningNodeClient {
    static let live = Self(
        start: { try await LightningNodeService.shared.start() },
        stop: { try LightningNodeService.shared.stop() },
        restart: { try await LightningNodeService.shared.restart() },
        reset: { try LightningNodeService.shared.reset() },
        nodeId: { LightningNodeService.shared.nodeId() },
        newAddress: { try await LightningNodeService.shared.newAddress() },
        balances: { await LightningNodeService.shared.listBalances() },
        spendableOnchainBalanceSats: {
            await LightningNodeService.shared.spendableOnchainBalanceSats()
        },
        totalOnchainBalanceSats: { await LightningNodeService.shared.totalOnchainBalanceSats() },
        totalLightningBalanceSats: {
            await LightningNodeService.shared.totalLightningBalanceSats()
        },
        lightningBalances: { await LightningNodeService.shared.lightningBalances() },
        pendingBalancesFromChannelClosures: {
            await LightningNodeService.shared.pendingBalancesFromChannelClosures()
        },
        connect: { nodeId, address, persist in
            try await LightningNodeService.shared.connect(
                nodeId: nodeId,
                address: address,
                persist: persist
            )
        },
        disconnect: { nodeId in try LightningNodeService.shared.disconnect(nodeId: nodeId) },
        connectOpenChannel: { nodeId, address, amount, pushMsat, config, announce in
            try await LightningNodeService.shared.connectOpenChannel(
                nodeId: nodeId,
                address: address,
                channelAmountSats: amount,
                pushToCounterpartyMsat: pushMsat,
                channelConfig: config,
                announceChannel: announce
            )
        },
        closeChannel: { channelId, nodeId in
            try LightningNodeService.shared.closeChannel(
                userChannelId: channelId,
                counterpartyNodeId: nodeId
            )
        },
        send: { uriStr in try await LightningNodeService.shared.send(uriStr: uriStr) },
        sendBolt11Payment: { invoice, sendingParameters in
            try await LightningNodeService.shared.sendBolt11Payment(
                invoice: invoice,
                sendingParameters: sendingParameters
            )
        },
        receive: { amount, message, expiry in
            try await LightningNodeService.shared.receive(
                amountSat: amount,
                message: message,
                expirySec: expiry
            )
        },
        bolt11Payment: { amount, description, expiry, maxFee, receiveViaJitChannel in
            try await LightningNodeService.shared.bolt11Payment(
                amountMsat: amount,
                description: description,
                expirySecs: expiry,
                maxLspFeeLimitMsat: maxFee,
                receiveViaJitChannel: receiveViaJitChannel
            )
        },
        listPeers: { LightningNodeService.shared.listPeers() },
        listChannels: { LightningNodeService.shared.listChannels() },
        listPayments: { LightningNodeService.shared.listPayments() },
        status: { LightningNodeService.shared.status() },
        deleteWallet: { try LightningNodeService.shared.deleteWallet() },
        getBackupInfo: { try LightningNodeService.shared.getBackupInfo() },
        deleteDocuments: { try LightningNodeService.shared.deleteDocuments() },
        getNetwork: { LightningNodeService.shared.network },
        getServer: { LightningNodeService.shared.server },
        getNetworkColor: { LightningNodeService.shared.networkColor },
        listenForEvents: { LightningNodeService.shared.listenForEvents() },
        syncWallets: { try LightningNodeService.shared.syncWallets() }
    )
}

extension LightningNodeClient {
    static let mock = Self(
        start: {},
        stop: {},
        restart: {},
        reset: {},
        nodeId: { "038474837483784378437843784378437843784378" },
        newAddress: { "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx" },
        balances: { .mock },
        spendableOnchainBalanceSats: { 100_000 },
        totalOnchainBalanceSats: { 150_000 },
        totalLightningBalanceSats: { 50_000 },
        lightningBalances: { [] },
        pendingBalancesFromChannelClosures: { [] },
        connect: { _, _, _ in },
        disconnect: { _ in },
        connectOpenChannel: { _, _, _, _, _, _ in UserChannelId("abcdef") },
        closeChannel: { _, _ in },
        send: { _ in QrPaymentResult.onchain(txid: "txid") },
        sendBolt11Payment: { _, _ in PaymentId("") },
        receive: { _, _, _ in
            "bitcoin:BC1QYLH3U67J673H6Y6ALV70M0PL2YZ53TZHVXGG7U?amount=0.00001&label=sbddesign%3A%20For%20lunch%20Tuesday&message=For%20lunch%20Tuesday&lightning=LNBC10U1P3PJ257PP5YZTKWJCZ5FTL5LAXKAV23ZMZEKAW37ZK6KMV80PK4XAEV5QHTZ7QDPDWD3XGER9WD5KWM36YPRX7U3QD36KUCMGYP282ETNV3SHJCQZPGXQYZ5VQSP5USYC4LK9CHSFP53KVCNVQ456GANH60D89REYKDNGSMTJ6YW3NHVQ9QYYSSQJCEWM5CJWZ4A6RFJX77C490YCED6PEMK0UPKXHY89CMM7SCT66K8GNEANWYKZGDRWRFJE69H9U5U0W57RRCSYSAS7GADWMZXC8C6T0SPJAZUP6&lightning=LNO1PG257ENXV4EZQCNEYPE82UM50YNHXGRWDAJX283QFWDPL28QQMC78YMLVHMXCSYWDK5WRJNJ36JRYG488QWLRNZYJCZS"
        },
        bolt11Payment: {
            _,
            _,
            _,
            _,
            _
            in try! Bolt11Invoice.fromStr(invoiceStr: "lnbc1...")
        },
        listPeers: { [] },
        listChannels: { [] },
        listPayments: { mockPayments },
        status: {
            NodeStatus(
                isRunning: true,
                isListening: true,
                currentBestBlock: BestBlock(
                    blockHash: BlockHash(
                        "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f"
                    ),
                    height: 123456
                ),
                latestLightningWalletSyncTimestamp: UInt64(Date().timeIntervalSince1970),
                latestOnchainWalletSyncTimestamp: UInt64(Date().timeIntervalSince1970),
                latestFeeRateCacheUpdateTimestamp: UInt64(Date().timeIntervalSince1970),
                latestRgsSnapshotTimestamp: UInt64(Date().timeIntervalSince1970),
                latestNodeAnnouncementBroadcastTimestamp: UInt64(Date().timeIntervalSince1970),
                latestChannelMonitorArchivalHeight: 123456
            )
        },
        deleteWallet: {},
        getBackupInfo: {
            BackupInfo(
                mnemonic: "test test test",
                networkString: Network.signet.description,
                serverURL: EsploraServer.mutiny_signet.url
            )
        },
        deleteDocuments: {},
        getNetwork: { .signet },
        getServer: { .mutiny_signet },
        getNetworkColor: { .orange },
        listenForEvents: {},
        syncWallets: {}
    )
}

let mockPayments: [PaymentDetails] = [
    .init(
        id: "1",
        kind: .bolt11(hash: "hash1", preimage: nil, secret: nil),
        amountMsat: 100_000_000,
        feePaidMsat: nil,
        direction: .inbound,
        status: .pending,
        latestUpdateTimestamp: UInt64(Date.now.timeIntervalSince1970)
    ),
    .init(
        id: "2",
        kind: .onchain(txid: "txid", status: .unconfirmed),
        amountMsat: 640_000_000,
        feePaidMsat: nil,
        direction: .inbound,
        status: .succeeded,
        latestUpdateTimestamp: UInt64(Date.now.addingTimeInterval(0.5 * 3600).timeIntervalSince1970)
    ),
    .init(
        id: "3",
        kind: .bolt11(hash: "hash3", preimage: nil, secret: nil),
        amountMsat: 340_000_000,
        feePaidMsat: nil,
        direction: .outbound,
        status: .succeeded,
        latestUpdateTimestamp: UInt64(Date.now.addingTimeInterval(3 * 3600).timeIntervalSince1970)
    ),
    .init(
        id: "4",
        kind: .bolt11(hash: "hash3", preimage: nil, secret: nil),
        amountMsat: 160_000_000,
        feePaidMsat: nil,
        direction: .inbound,
        status: .succeeded,
        latestUpdateTimestamp: UInt64(Date.now.addingTimeInterval(48 * 3600).timeIntervalSince1970)
    ),
    .init(
        id: "5",
        kind: .onchain(txid: "txid", status: .unconfirmed),
        amountMsat: 210_000_000,
        feePaidMsat: nil,
        direction: .outbound,
        status: .failed,
        latestUpdateTimestamp: 1_718_841_640
    ),
]

extension BalanceDetails {
    static let empty = BalanceDetails(
        totalOnchainBalanceSats: 0,
        spendableOnchainBalanceSats: 0,
        totalAnchorChannelsReserveSats: 0,
        totalLightningBalanceSats: 0,
        lightningBalances: [],
        pendingBalancesFromChannelClosures: []
    )
    static let mock = BalanceDetails(
        totalOnchainBalanceSats: 150000,
        spendableOnchainBalanceSats: 100000,
        totalAnchorChannelsReserveSats: 0,
        totalLightningBalanceSats: 50000,
        lightningBalances: [],
        pendingBalancesFromChannelClosures: []
    )
}
