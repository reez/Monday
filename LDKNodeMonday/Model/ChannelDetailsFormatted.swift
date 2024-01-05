//
//  ChannelDetailsFormatted.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 1/20/24.
//

import Foundation

struct ChannelDetailsFormatted: Identifiable {
    let id = UUID()
    let name: String
    let value: String
    let isCopyable: Bool
    var isCopied: Bool = false
}
