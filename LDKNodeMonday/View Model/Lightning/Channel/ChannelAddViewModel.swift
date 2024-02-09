//
//  ChannelAddViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import LDKNode
import SwiftUI

class ChannelAddViewModel: ObservableObject {
    @Published var address: String = "" {
        didSet {
            address = address.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    @Published var channelAmountSats: String = "" {
        didSet {
            channelAmountSats = channelAmountSats.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    @Published var channelAddViewError: MondayError?
    @Published var networkColor = Color.gray
    @Published var nodeId: PublicKey = "" {
        didSet {
            nodeId = nodeId.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    @Published var isOpenChannelFinished: Bool = false
    @Published var isProgressViewShowing: Bool = false

    private let channelConfig = ChannelConfig()

    init() {
        self.channelConfig.setForwardingFeeProportionalMillionths(value: UInt32(0))
        self.channelConfig.setForwardingFeeBaseMsat(feeMsat: UInt32(1000))
        self.channelConfig.setCltvExpiryDelta(value: UInt16(72))
        self.channelConfig.setMaxDustHtlcExposureFromFixedLimit(limitMsat: UInt64(50_000_000))
        self.channelConfig.setForceCloseAvoidanceMaxFeeSatoshis(valueSat: UInt64(1000))
    }

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

    func getColor() {
        let color = LightningNodeService.shared.networkColor
        DispatchQueue.main.async {
            self.networkColor = color
        }
    }

}
