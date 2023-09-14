//
//  View+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 9/14/23.
//

import Foundation
import SwiftUI

extension View {
    func applyFidgetEffect(viewState: Binding<CGSize>) -> some View {
        self
            .offset(x: -viewState.wrappedValue.width, y: -viewState.wrappedValue.height)
            .rotation3DEffect(
                .degrees(viewState.wrappedValue.width),
                axis: (x: 0, y: 1, z: 0)
            )
    }
}
