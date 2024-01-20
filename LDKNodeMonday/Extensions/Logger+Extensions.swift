//
//  Logger+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 1/6/24.
//

import Foundation
import OSLog

public let iOSLogger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "iOS")

extension Logger {
    public static var subsystem = Bundle.main.bundleIdentifier!

    public static let debug = Logger(subsystem: subsystem, category: "debug")

    public static func log(
        _ message: String,
        type: OSLogType = .default,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        logger: Logger = iOSLogger
    ) {
        let fileName = (file as NSString).lastPathComponent
        logger.log(level: type, "[\(fileName):\(line)] \(function) - \(message)")
    }

}
