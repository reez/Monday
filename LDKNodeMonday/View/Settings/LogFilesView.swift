//
//  LogFilesView.swift
//  LDKNodeMonday
//
//  Created by Daniel Nordh on 08/05/2025.
//

import SwiftUI

struct LogFilesView: View {
    var body: some View {
        VStack {
            Text(
                "You can find the log files for Monday by going to the Files app on your device:\n\nFiles → On My iPhone → Monday"
            )
            .font(.body)
            .multilineTextAlignment(.center)
            .padding(40)
        }.dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .navigationTitle("Log Files")
            .navigationBarTitleDisplayMode(.inline)
            .padding(.bottom, 40.0)
    }
}

#Preview {
    LogFilesView()
}
