//
//  FileManager+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import Foundation

extension FileManager {
    static func deleteLogFile() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let logFilePath = URL(fileURLWithPath: documentsPath).appendingPathComponent("ldk_node.log").path
        
        do {
            try FileManager.default.removeItem(atPath: logFilePath)
            print("Log file deleted successfully")
        } catch {
            print("Error deleting log file: \(error.localizedDescription)")
        }
    }
}
