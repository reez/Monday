//
//  EventService.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 12/29/23.
//

import Foundation
import LDKNode

class EventService: ObservableObject {
    @Published var lastMessage: String? = nil

    init() {
        NotificationCenter.default.addObserver(
            forName: .ldkEventReceived,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let message = notification.object as? String {
                self?.lastMessage = message
            }
        }

        NotificationCenter.default.addObserver(
            forName: .ldkErrorReceived,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let error = notification.object as? NodeError {
                let errorDetails = handleNodeError(error)
                self?.lastMessage = "\(errorDetails.title)"  //: \(errorDetails.detail)"
            } else {
                self?.lastMessage = "\(notification.object.debugDescription)"
            }
        }

    }
}
