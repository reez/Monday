//
//  LDKNodeMondayEvent.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/2/23.
//

import Foundation
import LightningDevKitNode

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

enum LDKNodeMondayEvent {
    case none
    case paymentSuccessful(paymentSuccessful: PaymentSuccessful)
    case paymentFailed(paymentFailed: PaymentFailed)
    case paymentReceived(paymentReceived: PaymentReceived)
    case channelReady(channelReady: ChannelReady)
    case channelClosed(channelClosed: ChannelClosed)
}

func convertToLDKNodeMondayEvent(event: Event) -> LDKNodeMondayEvent {
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
