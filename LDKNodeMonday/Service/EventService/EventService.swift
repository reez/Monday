//
//  EventService.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 12/29/23.
//

import Foundation
import LDKNode

class EventService: ObservableObject {
    @Published var lastEvent: Event? = nil

    init() {
        NotificationCenter.default.addObserver(
            forName: .ldkEventReceived,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let event = notification.object as? Event {
                self?.lastEvent = event
            } else {
                self?.lastEvent = nil  //"\(notification.object.debugDescription)"
            }
        }

        /* Don't use this
        NotificationCenter.default.addObserver(
            forName: .ldkErrorReceived,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let error = notification.object as? NodeError {
                let errorDetails = handleNodeError(error)
                self?.lastEvent = "\(errorDetails.title)"
            } else {
                self?.lastEvent = "\(notification.object.debugDescription)"
            }
        }
        */
    }
}
