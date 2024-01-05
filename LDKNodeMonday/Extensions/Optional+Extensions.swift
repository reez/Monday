//
//  Optional+Extensions.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 1/20/24.
//

import Foundation

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}
