//
//  LightningNodeError.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/28/23.
//

import Foundation
import LightningDevKitNode

struct MondayNodeError {
    let title: String
    let detail: String
}

func handleNodeError(_ error: NodeError) -> MondayNodeError {
    
    switch error {
        
    case .AlreadyRunning(message: let message):
        
        print("LDKNodeMonday /// MondayNodeError: AlreadyRunning \n \(message)")
        return .init(title: "AlreadyRunning", detail: message)
        
    case .NotRunning(message: let message):
        print("LDKNodeMonday /// MondayNodeError: NotRunning \n \(message)")
        return .init(title: "NotRunning", detail: message)
        
    case .ConnectionFailed(message: let message):
        print("LDKNodeMonday /// MondayNodeError: ConnectionFailed \n \(message)")
        return .init(title: "ConnectionFailed", detail: message)
        
    case .AddressInvalid(message: let message):
        print("LDKNodeMonday /// MondayNodeError: AddressInvalid \n \(message)")
        return .init(title: "AddressInvalid", detail: message)
        
    case .PublicKeyInvalid(message: let message):
        print("LDKNodeMonday /// MondayNodeError: PublicKeyInvalid \n \(message)")
        return .init(title: "PublicKeyInvalid", detail: message)
        
    case .PaymentHashInvalid(message: let message):
        print("LDKNodeMonday /// MondayNodeError: PaymentHashInvalid \n \(message)")
        return .init(title: "PaymentHashInvalid", detail: message)
        
    case .NonUniquePaymentHash(message: let message):
        print("LDKNodeMonday /// MondayNodeError: NonUniquePaymentHash \n \(message)")
        return .init(title: "NonUniquePaymentHash", detail: message)
        
    case .InvoiceCreationFailed(message: let message):
        print("LDKNodeMonday /// MondayNodeError: InvoiceCreationFailed \n \(message)")
        return .init(title: "InvoiceCreationFailed", detail: message)
        
    case .ChannelIdInvalid(message: let message):
        print("LDKNodeMonday /// MondayNodeError: ChannelIdInvalid \n \(message)")
        return .init(title: "ChannelIdInvalid", detail: message)
        
    case .NetworkInvalid(message: let message):
        print("LDKNodeMonday /// MondayNodeError: NetworkInvalid \n \(message)")
        return .init(title: "NetworkInvalid", detail: message)
        
    case .PeerInfoParseFailed(message: let message):
        print("LDKNodeMonday /// MondayNodeError: PeerInfoParseFailed \n \(message)")
        return .init(title: "PeerInfoParseFailed", detail: message)
        
    case .ChannelCreationFailed(message: let message):
        print("LDKNodeMonday /// MondayNodeError: ChannelCreationFailed \n \(message)")
        return .init(title: "ChannelCreationFailed", detail: message)
        
    case .ChannelClosingFailed(message: let message):
        print("LDKNodeMonday /// MondayNodeError: ChannelClosingFailed \n \(message)")
        return .init(title: "ChannelClosingFailed", detail: message)
        
    case .PersistenceFailed(message: let message):
        print("LDKNodeMonday /// MondayNodeError: PersistenceFailed \n \(message)")
        return .init(title: "PersistenceFailed", detail: message)
        
    case .WalletOperationFailed(message: let message):
        print("LDKNodeMonday /// MondayNodeError: WalletOperationFailed \n \(message)")
        return .init(title: "WalletOperationFailed", detail: message)
        
    case .WalletSigningFailed(message: let message):
        print("LDKNodeMonday /// MondayNodeError: WalletSigningFailed \n \(message)")
        return .init(title: "WalletSigningFailed", detail: message)
        
    case .TxSyncFailed(message: let message):
        print("LDKNodeMonday /// MondayNodeError: TxSyncFailed \n \(message)")
        return .init(title: "TxSyncFailed", detail: message)
        
    case .PaymentPreimageInvalid(message: let message):
        print("LDKNodeMonday /// MondayNodeError: PaymentPreimageInvalid \n \(message)")
        return .init(title: "PaymentPreimageInvalid", detail: message)
        
    case .PaymentSecretInvalid(message: let message):
        print("LDKNodeMonday /// MondayNodeError: PaymentSecretInvalid \n \(message)")
        return .init(title: "PaymentSecretInvalid", detail: message)
        
    case .InvalidAmount(message: let message):
        print("LDKNodeMonday /// MondayNodeError: InvalidAmount \n \(message)")
        return .init(title: "InvalidAmount", detail: message)
        
    case .InvalidInvoice(message: let message):
        print("LDKNodeMonday /// MondayNodeError: InvalidInvoice \n \(message)")
        return .init(title: "InvalidInvoice", detail: message)
        
    case .InsufficientFunds(message: let message):
        print("LDKNodeMonday /// MondayNodeError: InsufficientFunds \n \(message)")
        return .init(title: "InsufficientFunds", detail: message)
        
    case .PaymentFailed(message: let message):
        print("LDKNodeMonday /// MondayNodeError: PaymentFailed \n \(message)")
        return .init(title: "PaymentFailed", detail: message)
        
    case .OnchainTxCreationFailed(message: let message):
        print("LDKNodeMonday /// MondayNodeError: OnchainTxCreationFailed \n \(message)")
        return .init(title: "OnchainTxCreationFailed", detail: message)
        
    }
    
}
