//
//  LoadingView.swift
//  LDKNodeMonday
//
//  Created by Daniel Nordh on 16/01/2025.
//

import SwiftUI

struct LoadingView: View {

    var body: some View {

        VStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            Spacer()
        }
    }

}

#Preview {
    LoadingView()
}
