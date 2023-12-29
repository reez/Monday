//
//  FileManager+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import Foundation

extension FileManager {

    // Deletes log file before `start` to keep log file small and loadable in Log View
    static func deleteLDKNodeLogLatestFile() throws {
        let documentsPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        )[0]

        let logFilePath = URL(fileURLWithPath: documentsPath).appendingPathComponent(
            "logs/ldk_node_latest.log"
        ).path

        try FileManager.default.removeItem(atPath: logFilePath)
    }

}
