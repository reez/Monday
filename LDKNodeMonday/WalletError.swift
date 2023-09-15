//
//  WalletError.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 9/14/23.
//

import Foundation

enum WalletError: Error {
    case walletNotFound
    case blockchainConfigNotFound
}
