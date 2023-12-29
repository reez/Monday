//
//  SeedView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 12/30/23.
//

import LDKNode
import SwiftUI

class SeedViewModel: ObservableObject {
    @Published var seed: BackupInfo = .init(mnemonic: "mock seed words")

    func getSeed() {
        do {
            let seed = try LightningNodeService.shared.getBackupInfo()
            self.seed = seed
        } catch {
            // TODO: handle error
        }
    }

}

struct SeedView: View {
    @ObservedObject var viewModel: SeedViewModel

    var body: some View {

        VStack(alignment: .leading) {
            ForEach(
                Array(viewModel.seed.mnemonic.components(separatedBy: " ").enumerated()),
                id: \.element
            ) { index, word in
                HStack {
                    Text("\(index + 1). \(word)")
                    Spacer()
                }
                .padding(.horizontal, 40.0)
            }
        }
        .padding()
        .onAppear {
            viewModel.getSeed()
        }

    }
}

#Preview {
    SeedView(viewModel: .init())
}
