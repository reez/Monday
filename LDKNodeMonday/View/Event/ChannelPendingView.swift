//
//  ChannelPendingView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/8/23.
//

import SwiftUI

struct ChannelPendingView: View {
    let channelPending: ChannelPending
    
    var body: some View {
        
        VStack(spacing: 10) {
            
            HStack {
                Image(systemName: "checkmark")
                Text("Channel Pending")
            }
            
            HStack {
                Text("Channel ID:")
                Text(channelPending.channelId.description)
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("User Channel ID:")
                Text(channelPending.userChannelId.description)
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
            }
            
        }
        .font(.system(.caption, design: .monospaced))
        .padding()
        
    }
}

struct ChannelPendingView_Previews: PreviewProvider {
    static var previews: some View {
        ChannelPendingView(channelPending: .init(
            channelId: "2ff575465c3aed395d5eaafbf0cd69bb1397b52dd34adfcc558a533ef62363a8",
            userChannelId: "8239503182322108192884638612024332137",
            formerTemporaryChannelId: "8239503182322108192884638612024332137",
            counterpartyNodeId: "8239503182322108192884638612024332137",
            fundingTxo: .init(txid: "8239503182322108192884638612024332137", vout: UInt32(21))
        )
        )
    }
}
