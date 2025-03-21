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
                self?.lastEvent = nil
            }
        }
    }
}
