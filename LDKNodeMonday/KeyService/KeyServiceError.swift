//
//  KeyServiceError.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 9/14/23.
//

import Foundation

enum KeyServiceError: Error {
    case encodingError
    case writeError
    case urlError
    case decodingError
    case readError
}
