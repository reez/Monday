//
//  LDKNodeMondayApp.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/20/23.
//

import SwiftUI

@main
struct LDKNodeMondayApp: App {
    
    var body: some Scene {
        WindowGroup {
            TabHomeView(viewModel: .init())
        }
    }
    
}
