//
//  PriceServiceError.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 1/20/24.
//

import Foundation

enum PriceServiceError: Error {
    case invalidURL
    case invalidServerResponse
    case serialization
}
