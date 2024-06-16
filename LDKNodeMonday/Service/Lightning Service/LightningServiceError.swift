//
//  LightningServiceError.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 3/4/24.
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

    case .ProbeSendingFailed(let message):
        return .init(title: "ProbeSendingFailed", detail: message)

    case .FeerateEstimationUpdateFailed(let message):
        return .init(title: "FeerateEstimationUpdateFailed", detail: message)

    case .InvalidSocketAddress(let message):
        return .init(title: "InvalidSocketAddress", detail: message)

    case .LiquidityRequestFailed(let message):
        return .init(title: "LiquidityRequestFailed", detail: message)

    case .LiquiditySourceUnavailable(let message):
        return .init(title: "LiquiditySourceUnavailable", detail: message)

    case .LiquidityFeeTooHigh(let message):
        return .init(title: "LiquidityFeeTooHigh", detail: message)

    case .InvalidPaymentId(let message):
        return .init(title: "InvalidPaymentId", detail: message)

    case .InvoiceRequestCreationFailed(let message):
        return .init(title: "InvoiceRequestCreationFailed", detail: message)

    case .OfferCreationFailed(let message):
        return .init(title: "OfferCreationFailed", detail: message)

    case .RefundCreationFailed(let message):
        return .init(title: "RefundCreationFailed", detail: message)

    case .InvalidOfferId(let message):
        return .init(title: "InvalidOfferId", detail: message)

    case .InvalidOffer(let message):
        return .init(title: "InvalidOffer", detail: message)

    case .InvalidRefund(let message):
        return .init(title: "InvalidRefund", detail: message)

    case .UnsupportedCurrency(let message):
        return .init(title: "UnsupportedCurrency", detail: message)

    case .InvalidNodeId(let message):
        return .init(title: "InvalidNodeId", detail: message)

    }

}
