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
        return pathString
    }

    func deleteAllContentsInDocuments() throws {
        let fileManager = FileManager.default
        let documentsURL = try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        let contents = try fileManager.contentsOfDirectory(
            at: documentsURL,
            includingPropertiesForKeys: nil,
            options: []
        )
        for fileURL in contents {
            try fileManager.removeItem(at: fileURL)
        }
    }
}
