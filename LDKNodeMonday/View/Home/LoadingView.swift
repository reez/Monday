//
//  StartView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/17/23.
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

#if DEBUG
    #Preview {

    }
#endif
