//
//  LightningStorage.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/21/23.
//

import Foundation
import LightningDevKitNode

struct LightningStorage {
    func getDocumentsDirectory() -> String {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let pathString = path.path
        print("LDKNodeMonday /// getDocumentsDirectory path: \n \(pathString)")
        return pathString
    }
}
