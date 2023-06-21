//
//  LightningStorage.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/21/23.
//

import Foundation
import LDKNode

struct LightningStorage {
    func getDocumentsDirectory() -> String {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let pathString = path.path
        print("pathString: \n \(pathString)")
        return pathString
    }
}
