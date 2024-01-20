//
//  Notification+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 12/29/23.
//

import Foundation

extension Notification.Name {
    static let ldkEventReceived = Notification.Name("ldkEventReceived")
    static let ldkErrorReceived = Notification.Name("ldkErrorReceived")
}
