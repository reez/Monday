//
//  LightningNodeError.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/28/23.
//

import Foundation
import LightningDevKitNode

struct MondayNodeError {
    
    init(nodeError: NodeError) {
        
        switch nodeError {
            
        case .AlreadyRunning(message: let message):
            print("LDKNodeMonday /// MondayNodeError: AlreadyRunning \n \(message)")
            
        case .NotRunning(message: let message):
            print("LDKNodeMonday /// MondayNodeError: NotRunning \n \(message)")
            
        case .FundingTxCreationFailed(message: let message):
            print("LDKNodeMonday /// MondayNodeError: FundingTxCreationFailed \n \(message)")
            
        case .ConnectionFailed(message: let message):
            print("LDKNodeMonday /// MondayNodeError: ConnectionFailed \n \(message)")
            
        case .AddressInvalid(message: let message):
            print("LDKNodeMonday /// MondayNodeError: AddressInvalid \n \(message)")
            
        case .PublicKeyInvalid(message: let message):
            print("LDKNodeMonday /// MondayNodeError: PublicKeyInvalid \n \(message)")
            
        case .PaymentHashInvalid(message: let message):
            print("LDKNodeMonday /// MondayNodeError: PaymentHashInvalid \n \(message)")
            
        case .NonUniquePaymentHash(message: let message):
            print("LDKNodeMonday /// MondayNodeError: NonUniquePaymentHash \n \(message)")
            
        case .InvoiceInvalid(message: let message):
            print("LDKNodeMonday /// MondayNodeError: InvoiceInvalid \n \(message)")
            
        case .InvoiceCreationFailed(message: let message):
            print("LDKNodeMonday /// MondayNodeError: InvoiceCreationFailed \n \(message)")
            
        case .ChannelIdInvalid(message: let message):
            print("LDKNodeMonday /// MondayNodeError: ChannelIdInvalid \n \(message)")
            
        case .NetworkInvalid(message: let message):
            print("LDKNodeMonday /// MondayNodeError: NetworkInvalid \n \(message)")
            
        case .RoutingFailed(message: let message):
            print("LDKNodeMonday /// MondayNodeError: RoutingFailed \n \(message)")
            
        case .PeerInfoParseFailed(message: let message):
            print("LDKNodeMonday /// MondayNodeError: PeerInfoParseFailed \n \(message)")
            
        case .ChannelCreationFailed(message: let message):
            print("LDKNodeMonday /// MondayNodeError: ChannelCreationFailed \n \(message)")
            
        case .ChannelClosingFailed(message: let message):
            print("LDKNodeMonday /// MondayNodeError: ChannelClosingFailed \n \(message)")
            
        case .PersistenceFailed(message: let message):
            print("LDKNodeMonday /// MondayNodeError: PersistenceFailed \n \(message)")
            
        case .WalletOperationFailed(message: let message):
            print("LDKNodeMonday /// MondayNodeError: WalletOperationFailed \n \(message)")
            
        case .WalletSigningFailed(message: let message):
            print("LDKNodeMonday /// MondayNodeError: WalletSigningFailed \n \(message)")
            
        case .TxSyncFailed(message: let message):
            print("LDKNodeMonday /// MondayNodeError: TxSyncFailed \n \(message)")
            
        }
        
    }
    
}
