//
//  ErrorView.swift
//  LDKNodeMonday
//
//  Created by Daniel Nordh on 16/01/2025.
//

import SwiftUI

struct ErrorView: View {

    var error: Error?

    var body: some View {
        Spacer()
        Text(error != nil ? error!.localizedDescription : "Unknown error")
        Spacer()
    }
}

#Preview {
    ErrorView(
        error: NSError(
            domain: "com.example",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Unknown error"]
        )
    )
}
