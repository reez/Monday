//
//  MondayNodeError.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/28/23.
//

import Foundation
import LightningDevKitNode

struct MondayError {
    let title: String
    let detail: String
}

func handleNodeError(_ error: NodeError) -> MondayError {
    
    switch error {
        
    case .AlreadyRunning(message: let message):
        
        return .init(title: "AlreadyRunning", detail: message)
        
    case .NotRunning(message: let message):
        return .init(title: "NotRunning", detail: message)
        
    case .ConnectionFailed(message: let message):
        return .init(title: "ConnectionFailed", detail: message)
        
    case .AddressInvalid(message: let message):
        return .init(title: "AddressInvalid", detail: message)
        
    case .PublicKeyInvalid(message: let message):
        return .init(title: "PublicKeyInvalid", detail: message)
        
    case .PaymentHashInvalid(message: let message):
        return .init(title: "PaymentHashInvalid", detail: message)
        
    case .NonUniquePaymentHash(message: let message):
        return .init(title: "NonUniquePaymentHash", detail: message)
        
    case .InvoiceCreationFailed(message: let message):
        return .init(title: "InvoiceCreationFailed", detail: message)
        
    case .ChannelIdInvalid(message: let message):
        return .init(title: "ChannelIdInvalid", detail: message)
        
    case .NetworkInvalid(message: let message):
        return .init(title: "NetworkInvalid", detail: message)
        
    case .PeerInfoParseFailed(message: let message):
        return .init(title: "PeerInfoParseFailed", detail: message)
        
    case .ChannelCreationFailed(message: let message):
        return .init(title: "ChannelCreationFailed", detail: message)
        
    case .ChannelClosingFailed(message: let message):
        return .init(title: "ChannelClosingFailed", detail: message)
        
    case .PersistenceFailed(message: let message):
        return .init(title: "PersistenceFailed", detail: message)
        
    case .WalletOperationFailed(message: let message):
        return .init(title: "WalletOperationFailed", detail: message)
        
    case .WalletSigningFailed(message: let message):
        return .init(title: "WalletSigningFailed", detail: message)
        
    case .TxSyncFailed(message: let message):
        return .init(title: "TxSyncFailed", detail: message)
        
    case .PaymentPreimageInvalid(message: let message):
        return .init(title: "PaymentPreimageInvalid", detail: message)
        
    case .PaymentSecretInvalid(message: let message):
        return .init(title: "PaymentSecretInvalid", detail: message)
        
    case .InvalidAmount(message: let message):
        return .init(title: "InvalidAmount", detail: message)
        
    case .InvalidInvoice(message: let message):
        return .init(title: "InvalidInvoice", detail: message)
        
    case .InsufficientFunds(message: let message):
        return .init(title: "InsufficientFunds", detail: message)
        
    case .PaymentFailed(message: let message):
        return .init(title: "PaymentFailed", detail: message)
        
    case .OnchainTxCreationFailed(message: let message):
        return .init(title: "OnchainTxCreationFailed", detail: message)
        
    }
    
}
