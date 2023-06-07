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
        
    case .InvoiceCreationFailed(message: let message):
        return .init(title: "InvoiceCreationFailed", detail: message)
        
    case .ChannelCreationFailed(message: let message):
        return .init(title: "ChannelCreationFailed", detail: message)
        
    case .ChannelClosingFailed(message: let message):
        return .init(title: "ChannelClosingFailed", detail: message)
        
    case .PersistenceFailed(message: let message):
        return .init(title: "PersistenceFailed", detail: message)
        
    case .WalletOperationFailed(message: let message):
        return .init(title: "WalletOperationFailed", detail: message)
   
    case .TxSyncFailed(message: let message):
        return .init(title: "TxSyncFailed", detail: message)
        
    case .InvalidAmount(message: let message):
        return .init(title: "InvalidAmount", detail: message)
        
    case .InvalidInvoice(message: let message):
        return .init(title: "InvalidInvoice", detail: message)
        
    case .InsufficientFunds(message: let message):
        return .init(title: "InsufficientFunds", detail: message)
         
    case .OnchainTxCreationFailed(message: let message):
        return .init(title: "OnchainTxCreationFailed", detail: message)
        
    case .PaymentSendingFailed(message: let message):
        return .init(title: "PaymentSendingFailed", detail: message)

    case .OnchainTxSigningFailed(message: let message):
        return .init(title: "OnchainTxSigningFailed", detail: message)

    case .MessageSigningFailed(message: let message):
        // TODO:
        return .init(title: "MessageSigningFailed", detail: message)

    case .GossipUpdateFailed(message: let message):
        return .init(title: "GossipUpdateFailed", detail: message)

    case .InvalidAddress(message: let message):
        return .init(title: "InvalidAddress", detail: message)

    case .InvalidNetAddress(message: let message):
        return .init(title: "InvalidNetAddress", detail: message)

    case .InvalidPublicKey(message: let message):
        return .init(title: "InvalidPublicKey", detail: message)

    case .InvalidSecretKey(message: let message):
        return .init(title: "InvalidSecretKey", detail: message)

    case .InvalidPaymentHash(message: let message):
        return .init(title: "InvalidPaymentHash", detail: message)

    case .InvalidPaymentPreimage(message: let message):
        return .init(title: "InvalidPaymentPreimage", detail: message)

    case .InvalidPaymentSecret(message: let message):
        return .init(title: "InvalidPaymentSecret", detail: message)

    case .InvalidChannelId(message: let message):
        return .init(title: "InvalidChannelId", detail: message)

    case .InvalidNetwork(message: let message):
        return .init(title: "InvalidNetwork", detail: message)

    case .DuplicatePayment(message: let message):
        return .init(title: "DuplicatePayment", detail: message)

    }
    
}
