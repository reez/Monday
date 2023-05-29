//
//  FileManager+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import Foundation

extension FileManager {
    static func deleteLDKNodeLogFile() throws {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let logFilePath = URL(fileURLWithPath: documentsPath).appendingPathComponent("ldk_node.log").path
        try FileManager.default.removeItem(atPath: logFilePath)
    }
}
