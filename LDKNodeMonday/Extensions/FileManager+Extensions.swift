//
//  FileManager+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 3/4/24.
//

import Foundation

extension FileManager {
    func getDocumentsDirectoryPath() -> String {
        let path = URL.documentsDirectory.path
        return path
    }

    func deleteAllContentsInDocumentsDirectory() throws {
        let documentsURL = URL.documentsDirectory
        let contents = try contentsOfDirectory(
            at: documentsURL,
            includingPropertiesForKeys: nil,
            options: []
        )
        for fileURL in contents {
            try removeItem(at: fileURL)
        }
    }
}
