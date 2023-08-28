//
//  MondayNodeError.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/28/23.
//

import Foundation
import LDKNode

struct MondayError {
    let title: String
    let detail: String
}

func handleNodeError(_ error: NodeError) -> MondayError {

    switch error {

    case .AlreadyRunning(let message):

        return .init(title: "AlreadyRunning", detail: message)

    case .NotRunning(let message):
        return .init(title: "NotRunning", detail: message)

    case .ConnectionFailed(let message):
        return .init(title: "ConnectionFailed", detail: message)

    case .InvoiceCreationFailed(let message):
        return .init(title: "InvoiceCreationFailed", detail: message)

    case .ChannelCreationFailed(let message):
        return .init(title: "ChannelCreationFailed", detail: message)

    case .ChannelClosingFailed(let message):
        return .init(title: "ChannelClosingFailed", detail: message)

    case .PersistenceFailed(let message):
        return .init(title: "PersistenceFailed", detail: message)

    case .WalletOperationFailed(let message):
        return .init(title: "WalletOperationFailed", detail: message)

    case .TxSyncFailed(let message):
        return .init(title: "TxSyncFailed", detail: message)

    case .InvalidAmount(let message):
        return .init(title: "InvalidAmount", detail: message)

    case .InvalidInvoice(let message):
        return .init(title: "InvalidInvoice", detail: message)

    case .InsufficientFunds(let message):
        return .init(title: "InsufficientFunds", detail: message)

    case .OnchainTxCreationFailed(let message):
        return .init(title: "OnchainTxCreationFailed", detail: message)

    case .PaymentSendingFailed(let message):
        return .init(title: "PaymentSendingFailed", detail: message)

    case .OnchainTxSigningFailed(let message):
        return .init(title: "OnchainTxSigningFailed", detail: message)

    case .MessageSigningFailed(let message):
        return .init(title: "MessageSigningFailed", detail: message)

    case .GossipUpdateFailed(let message):
        return .init(title: "GossipUpdateFailed", detail: message)

    case .InvalidAddress(let message):
        return .init(title: "InvalidAddress", detail: message)

    case .InvalidNetAddress(let message):
        return .init(title: "InvalidNetAddress", detail: message)

    case .InvalidPublicKey(let message):
        return .init(title: "InvalidPublicKey", detail: message)

    case .InvalidSecretKey(let message):
        return .init(title: "InvalidSecretKey", detail: message)

    case .InvalidPaymentHash(let message):
        return .init(title: "InvalidPaymentHash", detail: message)

    case .InvalidPaymentPreimage(let message):
        return .init(title: "InvalidPaymentPreimage", detail: message)

    case .InvalidPaymentSecret(let message):
        return .init(title: "InvalidPaymentSecret", detail: message)

    case .InvalidChannelId(let message):
        return .init(title: "InvalidChannelId", detail: message)

    case .InvalidNetwork(let message):
        return .init(title: "InvalidNetwork", detail: message)

    case .DuplicatePayment(let message):
        return .init(title: "DuplicatePayment", detail: message)

    case .ChannelConfigUpdateFailed(let message):
        return .init(title: "ChannelConfigUpdateFailed", detail: message)

    }

}
