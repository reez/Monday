//
//  ChannelCloseView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/2/23.
//

import BitcoinUI
import LDKNode
import SwiftUI

struct ChannelDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ChannelDetailViewModel
    @Binding var refreshFlag: Bool
    @State private var showingChannelDetailViewErrorAlert = false
    @State private var isCopied = false
    @State private var showCheckmark = false
    @State private var lastCopiedItemId: String? = nil
    @State private var showingConfirmationAlert = false

    var body: some View {

        VStack {

            List(viewModel.channel.formatted(), id: \.name) { property in
                HStack {
                    VStack(alignment: .leading) {
                        Text(property.name)
                            .font(.subheadline.weight(.medium))
                        Text(property.value)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .truncationMode(.middle)
                            .lineLimit(1)

                    }
                    if property.isCopyable {
                        Button {
                            UIPasteboard.general.string = property.value
                            lastCopiedItemId = property.name
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                lastCopiedItemId = nil
                            }
                        } label: {
                            HStack {
                                withAnimation {
                                    Image(
                                        systemName: lastCopiedItemId == property.name
                                            ? "checkmark" : "doc.on.doc"
                                    )
                                }
                            }
                            .foregroundColor(.accentColor)
                            .padding(.leading, 10)
                        }
                    }
                }
                .padding(.top, 5)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)

            Spacer()

        }.dynamicTypeSize(...DynamicTypeSize.accessibility1)  // Sets max dynamic size for all Text
            .navigationTitle("Channel details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        showingConfirmationAlert = true
                    }
                    .foregroundColor(.red)
                    .padding()
                }
            }
            .alert(isPresented: $showingChannelDetailViewErrorAlert) {
                Alert(
                    title: Text(viewModel.channelDetailViewError?.title ?? "Unknown"),
                    message: Text(viewModel.channelDetailViewError?.detail ?? ""),
                    dismissButton: .default(Text("OK")) {
                        viewModel.channelDetailViewError = nil
                    }
                )
            }
            .alert(
                "Are you sure you want to close this channel?",
                isPresented: $showingConfirmationAlert
            ) {
                Button("Yes", role: .destructive) {
                    viewModel.close()
                    refreshFlag = true
                    if !showingChannelDetailViewErrorAlert {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                Button("No", role: .cancel) {}
            }
            .onReceive(viewModel.$channelDetailViewError) { errorMessage in
                if errorMessage != nil {
                    showingChannelDetailViewErrorAlert = true
                }
            }

    }
}

#if DEBUG
    #Preview {
        ChannelDetailView(
            viewModel: .init(
                channel: ChannelDetails(
                    channelId: ChannelId(stringLiteral: "channelID"),
                    counterpartyNodeId: PublicKey(stringLiteral: "counterpartyNodeId"),
                    fundingTxo: nil,
                    channelValueSats: UInt64(1_000_000),
                    unspendablePunishmentReserve: nil,
                    userChannelId: UserChannelId(stringLiteral: "userChannelId"),
                    feerateSatPer1000Weight: UInt32(20000),
                    outboundCapacityMsat: UInt64(500000),
                    inboundCapacityMsat: UInt64(400000),
                    confirmationsRequired: nil,
                    confirmations: nil,
                    isOutbound: false,
                    isChannelReady: true,
                    isUsable: true,
                    isAnnounced: true,
                    cltvExpiryDelta: nil,
                    counterpartyUnspendablePunishmentReserve: UInt64(1000),
                    counterpartyOutboundHtlcMinimumMsat: nil,
                    counterpartyOutboundHtlcMaximumMsat: nil,
                    counterpartyForwardingInfoFeeBaseMsat: nil,
                    counterpartyForwardingInfoFeeProportionalMillionths: nil,
                    counterpartyForwardingInfoCltvExpiryDelta: nil,
                    nextOutboundHtlcLimitMsat: UInt64(1000),
                    nextOutboundHtlcMinimumMsat: UInt64(1000),
                    forceCloseSpendDelay: nil,
                    inboundHtlcMinimumMsat: UInt64(1000),
                    inboundHtlcMaximumMsat: nil,
                    config: .init(
                        forwardingFeeProportionalMillionths: UInt32(21),
                        forwardingFeeBaseMsat: UInt32(21),
                        cltvExpiryDelta: UInt16(2),
                        maxDustHtlcExposure: .feeRateMultiplier(multiplier: UInt64(21)),
                        forceCloseAvoidanceMaxFeeSatoshis: UInt64(21),
                        acceptUnderpayingHtlcs: false
                    )
                )
            ),
            refreshFlag: .constant(false)
        )
    }
#endif
