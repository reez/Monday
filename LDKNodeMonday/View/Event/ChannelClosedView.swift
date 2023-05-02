//
//  ChannelClosedView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/2/23.
//

import SwiftUI

struct ChannelClosedView: View {
    let channelClosed: ChannelClosed
    
    var body: some View {
        
        VStack(spacing: 10) {
            
            HStack {
                Image(systemName: "xmark")
                Text("Channel Closed")
            }
            
            HStack {
                Text("Channel ID:")
                Text(channelClosed.channelId.description)
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("User Channel ID:")
                Text(channelClosed.userChannelId.description)
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
            }
            
        }
        .font(.system(.caption, design: .monospaced))
        .padding()
        
    }
}


struct ChannelClosedView_Previews: PreviewProvider {
    static var previews: some View {
        ChannelClosedView(
            channelClosed: .init(
                channelId: "2ff575465c3aed395d5eaafbf0cd69bb1397b52dd34adfcc558a533ef62363a8",
                userChannelId: "8239503182322108192884638612024332137"
            )
        )
    }
}
