//
//  ChannelAddViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import SwiftUI
import LDKNode

class ChannelAddViewModel: ObservableObject {
    @Published var address: String = ""
    @Published var channelAmountSats: String = ""
    @Published var channelAddViewError: MondayError?
    @Published var networkColor = Color.gray
    @Published var nodeId: PublicKey = ""
    @Published var isOpenChannelFinished: Bool = false
    @Published var isProgressViewShowing: Bool = false
    
    // Use default values other than maxDust
    // https://docs.rs/lightning/latest/lightning/util/config/struct.ChannelConfig.html#structfield.max_dust_htlc_exposure_msat
    private let channelConfig = ChannelConfig(
        forwardingFeeProportionalMillionths: UInt32(0),
        forwardingFeeBaseMsat: UInt32(1000),
        cltvExpiryDelta: UInt16(72),
        maxDustHtlcExposureMsat: 50_000_000, // Default is 5_000_000, raising to 50_000_000
        forceCloseAvoidanceMaxFeeSatoshis: UInt64(1000)
    )
    
    func openChannel(nodeId: PublicKey, address: String, channelAmountSats: UInt64, pushToCounterpartyMsat: UInt64?) async {
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
                self.channelAddViewError = .init(title: errorString.title, detail: errorString.detail)
            }
        } catch {
            DispatchQueue.main.async {
                self.isProgressViewShowing = false
                self.channelAddViewError = .init(title: "Unexpected error", detail: error.localizedDescription)
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
