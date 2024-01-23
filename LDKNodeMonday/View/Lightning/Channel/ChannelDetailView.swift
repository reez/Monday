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
    @ObservedObject var viewModel: ChannelDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingChannelDetailViewErrorAlert = false
    @Binding var refreshFlag: Bool
    @State private var isCopied = false
    @State private var showCheckmark = false
    @State private var lastCopiedItemId: String? = nil
    @State private var showingConfirmationAlert = false

    var body: some View {

        ZStack {
            Color(uiColor: UIColor.systemBackground)

            VStack {

                Spacer()

                Text(viewModel.channel.isOutbound ? "Outbound" : "Inbound").bold()
                    .padding()
                    .padding(.top, 120.0)

                List(viewModel.channel.formatted(), id: \.name) { property in
                    HStack {
                        Text(property.name)
                        Spacer()
                        Text(property.value)
                            .foregroundColor(.secondary)
                            .truncationMode(.middle)
                            .lineLimit(1)
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
                                .foregroundColor(viewModel.networkColor)
                                .padding(.leading, 8)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .font(.system(.caption2, design: .monospaced))
                .listStyle(.plain)

                Button {
                    showingConfirmationAlert = true
                } label: {
                    Text("Close Channel")
                        .bold()
                        .foregroundColor(Color(uiColor: UIColor.systemBackground))
                        .frame(maxWidth: .infinity)
                        .padding(.all, 8)
                }
                .buttonBorderShape(.capsule)
                .buttonStyle(.borderedProminent)
                .tint(viewModel.networkColor)
                .padding(.horizontal)
                .padding(.bottom, 120.0)

                Spacer()

            }
            .padding()
            .padding(.vertical, 20.0)
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
            .onAppear {
                viewModel.getColor()
            }

        }
        .ignoresSafeArea()

    }
}

struct ChannelCloseView_Previews: PreviewProvider {

    static var previews: some View {
        let channel = ChannelDetails(
            channelId: ChannelId(stringLiteral: "channelID"),
            counterpartyNodeId: PublicKey(stringLiteral: "counterpartyNodeId"),
            fundingTxo: nil,
            channelValueSats: UInt64(1_000_000),
            unspendablePunishmentReserve: nil,
            userChannelId: UserChannelId(stringLiteral: "userChannelId"),
            feerateSatPer1000Weight: UInt32(20000),
            balanceMsat: UInt64(2_000_000),
            outboundCapacityMsat: UInt64(500000),
            inboundCapacityMsat: UInt64(400000),
            confirmationsRequired: nil,
            confirmations: nil,
            isOutbound: false,
            isChannelReady: true,
            isUsable: true,
            isPublic: true,
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
            config: .init()
        )
        ChannelDetailView(viewModel: .init(channel: channel), refreshFlag: .constant(false))
        ChannelDetailView(viewModel: .init(channel: channel), refreshFlag: .constant(false))
            .environment(\.colorScheme, .dark)
    }

}
