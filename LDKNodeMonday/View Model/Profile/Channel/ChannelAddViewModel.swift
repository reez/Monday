//
//  ChannelAddViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import LDKNode
import SwiftUI

class ChannelAddViewModel: ObservableObject {
    @Published var address: String = ""
    @Published var channelAmountSats: String = ""
    @Published var channelAddViewError: MondayError?
    @Published var nodeId: PublicKey = ""
    @Published var isOpenChannelFinished: Bool = false
    @Published var isProgressViewShowing: Bool = false
    private let channelConfig = ChannelConfig(
        forwardingFeeProportionalMillionths: UInt32(0),
        forwardingFeeBaseMsat: UInt32(1000),
        cltvExpiryDelta: UInt16(72),
        maxDustHtlcExposure: .feeRateMultiplier(multiplier: UInt64(50_000_000)),
        forceCloseAvoidanceMaxFeeSatoshis: UInt64(1000),
        acceptUnderpayingHtlcs: false
    )

    func openChannel(
        nodeId: PublicKey,
        address: String,
        channelAmountSats: UInt64,
        pushToCounterpartyMsat: UInt64?
    ) async {
        DispatchQueue.main.async {
            self.isProgressViewShowing = true
        }
        do {
            try await LightningNodeService.shared.connectOpenChannel(
                nodeId: nodeId,
                address: address,
                channelAmountSats: channelAmountSats,
                pushToCounterpartyMsat: pushToCounterpartyMsat,
                channelConfig: channelConfig
            )
            DispatchQueue.main.async {
                self.channelAddViewError = nil
                self.isOpenChannelFinished = true
                self.isProgressViewShowing = false
            }
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.isProgressViewShowing = false
                self.channelAddViewError = .init(
                    title: errorString.title,
                    detail: errorString.detail
                )
            }
        } catch {
            DispatchQueue.main.async {
                self.isProgressViewShowing = false
                self.channelAddViewError = .init(
                    title: "Unexpected error",
                    detail: error.localizedDescription
                )
            }
        }
    }

}
