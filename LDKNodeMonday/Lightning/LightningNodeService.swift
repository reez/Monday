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
//    var eventState = EventState.none
    var myEvent = MyEvent.none
    
    class var shared: LightningNodeService {
        struct Singleton {
            static let instance = LightningNodeService(network: .regtest)
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
            listeningAddress = "127.0.0.1:2323"
            print("LDKNodeMonday /// Network chosen: \(chosenNetwork)")
        case .testnet:
            chosenNetwork = "testnet"
            esploraServerUrl = "http://blockstream.info/testnet/api/"
            listeningAddress = "0.0.0.0:9735"
            print("LDKNodeMonday /// Network chosen: \(chosenNetwork)")
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
        } catch {
            print("LDKNodeMonday /// error starting node: \(error.localizedDescription)")
        }
    }
    
    func stop() async throws {
        do {
            try node.stop()
            print("LDKNodeMonday /// Stopped node!")
        } catch {
            print("LDKNodeMonday /// error stopping node: \(error.localizedDescription)")
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
    
    func sendPayment(invoice: Invoice) {
        do {
            let paymentHash = try node.sendPayment(invoice: invoice)
            print("LDKNodeMonday /// sendPayment paymentHash: \(paymentHash)")
        } catch {
            if let mine = error as? NodeError {
                // TODO: do something when catching error here, you'll see it with a bad invoice like lnbc10u1pwzj6u7pp5p8l6arvcj6mpw4um4x7xvj2pw6j3q9g2q3e7f44plzupn5g5n5sdqsd5v5sxqrrssycnqar0dakjapqrxqzjccqzpgxqyz5vq5s5l5v0fydrf7g9j82pxf6jtakz6m8h6j4g6amw4m0rr4x2swk6jl9r9emr0r7jvkd8zjwd48azl6kwsuuc7s0vfh8y8z9p9xlkwlfh7yy43v8f8j3nfgqkg2qy7at94xj8f8r9ckzr0r
                let _ = MondayNodeError(nodeError: mine)
            } else {
                print("LDKNodeMonday /// sendPayment couldn't equate error to Node Error")
            }
        }
    }
    
    func receivePayment(amountMsat: UInt64, description: String, expirySecs: UInt32) -> Invoice? {
        do {
            let invoice = try node.receivePayment(amountMsat: amountMsat, description: description, expirySecs: expirySecs)
            return invoice
        } catch {
            print("LDKNodeMonday /// receivePayment couldn't equate error to Node Error")
            return nil
        }
    }
    
    func listChannels() -> [ChannelDetails] {
        let channels = node.listChannels()
        print("LDKNodeMonday /// listChannels: \(channels)")
        return channels
    }
    
}




// Currently unused
extension LightningNodeService {
    

    
    func nextEvent() {
        let nextEvent = node.nextEvent()
        print("LDKNodeMonday /// nextEvent: \n \(nextEvent)")
        
        switch nextEvent {
            
        case .paymentSuccessful(paymentHash: let paymentHash):
            print("LDKNodeMonday /// event: paymentSuccessful \n paymentHash \(paymentHash)")
            //self.eventState = .paymentSuccessful(paymentHash)
            
        case .paymentFailed(paymentHash: let paymentHash):
            print("LDKNodeMonday /// event: paymentFailed \n paymentHash \(paymentHash)")
            //self.eventState = .paymentFailed(paymentHash)
            
        case .paymentReceived(paymentHash: let paymentHash, amountMsat: let amountMsat):
            print("LDKNodeMonday /// event: paymentReceived \n paymentHash \(paymentHash) \n amountMsat \(amountMsat)")
            //self.eventState = .paymentReceived(paymentHash, amountMsat)
            
        case .channelReady(channelId: let channelId, userChannelId: let userChannelId):
            print("LDKNodeMonday /// event: channelReady \n channelId \(channelId) \n userChannelId \(userChannelId)")
            //self.eventState = .channelReady(channelId, userChannelId)
            let a = convertToMyEvent(event: .channelReady(channelId: channelId, userChannelId: userChannelId))
            self.myEvent = a
            
        case .channelClosed(channelId: let channelId, userChannelId: let userChannelId):
            print("LDKNodeMonday /// event: channelClosed \n channelId \(channelId) \n userChannelId \(userChannelId)")
            //self.eventState = .channelClosed(channelId, userChannelId)
            
        }
        
    }
    
    func eventHandled() {
        node.eventHandled()
        print("LDKNodeMonday /// eventHandled")
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
    
    func closeChannel(channelId: ChannelId, counterpartyNodeId: PublicKey) {
        print("LDKNodeMonday /// closeChannel")
        do {
            try node.closeChannel(channelId: channelId, counterpartyNodeId: counterpartyNodeId)
        } catch {
            print("LDKNodeMonday /// error on closeChannel: \(error.localizedDescription)")
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
        guard let paymentInfo = node.paymentInfo(paymentHash: paymentHash) else { return }
        print("LDKNodeMonday /// paymentInfo: \(paymentInfo)")
    }
    
    func listPeers() {
        print("LDKNodeMonday /// listPeers")
        let peers = node.listPeers()
        print("LDKNodeMonday /// listPeers peers: \(peers)")
    }
    
}



enum EventState {
    case none
    case paymentSuccessful(PaymentHash)
    case paymentFailed(PaymentHash)
    case paymentReceived(PaymentHash, UInt64)
    case channelReady(ChannelId, UserChannelId)
    case channelClosed(ChannelId, UserChannelId)
    
    var description: String {
          switch self {
          case .none:
              return "none"
          case .paymentSuccessful(let paymentHash):
              return "paymentSuccessful(\(paymentHash))"
          case .paymentFailed(let paymentHash):
              return "paymentFailed(\(paymentHash))"
          case .paymentReceived(let paymentHash, let amount):
              return "paymentReceived(\(paymentHash), \(amount))"
          case .channelReady(let channelId, let userChannelId):
              // I'd like to return a type here, but I'm not sure its possible because I'll return multiple types, and I don't think I can conform to Event
              return "channelReady(\(channelId), \(userChannelId))"
          case .channelClosed(let channelId, let userChannelId):
              return "channelClosed(\(channelId), \(userChannelId))"
          }
      }
    
}



struct PaymentReceived {
    let paymentHash: PaymentHash
    let amountMsat: UInt64
}

struct PaymentSuccessful {
    let paymentHash: PaymentHash
}

struct PaymentFailed {
    let paymentHash: PaymentHash
}

struct ChannelReady {
    let channelId: ChannelId
    let userChannelId: UserChannelId
}

struct ChannelClosed {
    let channelId: ChannelId
    let userChannelId: UserChannelId
}


enum MyEvent {
    case none
    case paymentSuccessful(paymentSuccessful: PaymentSuccessful)
    case paymentFailed(paymentFailed: PaymentFailed)
    case paymentReceived(paymentReceived: PaymentReceived)
    case channelReady(channelReady: ChannelReady)
    case channelClosed(channelClosed: ChannelClosed)
}


func convertToMyEvent(event: Event) -> MyEvent {
    switch event {
    case .paymentSuccessful(let paymentHash):
        let paymentSuccessful = PaymentSuccessful(paymentHash: paymentHash)
        return .paymentSuccessful(paymentSuccessful: paymentSuccessful)
    case .paymentFailed(let paymentHash):
        let paymentFailed = PaymentFailed(paymentHash: paymentHash)
        return .paymentFailed(paymentFailed: paymentFailed)
    case .paymentReceived(let paymentHash, let amountMsat):
        let paymentReceived = PaymentReceived(paymentHash: paymentHash, amountMsat: amountMsat)
        return .paymentReceived(paymentReceived: paymentReceived)
    case .channelReady(let channelId, let userChannelId):
        let channelReady = ChannelReady(channelId: channelId, userChannelId: userChannelId)
        return .channelReady(channelReady: channelReady)
    case .channelClosed(let channelId, let userChannelId):
        let channelClosed = ChannelClosed(channelId: channelId, userChannelId: userChannelId)
        return .channelClosed(channelClosed: channelClosed)
    }
}

