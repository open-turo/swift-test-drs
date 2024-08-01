//
// Created on 5/23/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// `FunctionSignature` is used to represent the signature of a function.
public struct FunctionSignature: Equatable, Hashable, Sendable {

    /// The full text of the function signature.
    let text: String

    /// The name of the function, that is everything up to but not including the left parenthesis.
    var name: Substring { text.prefix(while: { $0 != "(" }) }

    /// True if this signature is only the name of the function and does not include the parenthesis and argument labels.
    var isAbbreviated: Bool { name == text }

    /// A pattern matching operator that compares two `FunctionSignature` instances.
    /// If either signature is abbreviated (i.e., it only includes the function name), then only the names of the functions are compared.
    /// Otherwise, the full text of the function signatures is compared.
    static func ~= (lhs: FunctionSignature, rhs: FunctionSignature) -> Bool {
        if lhs.isAbbreviated || rhs.isAbbreviated {
            return lhs.name == rhs.name
        }

        return lhs.text == rhs.text
    }
}

// MARK: ExpressibleByStringLiteral
extension FunctionSignature: ExpressibleByStringLiteral {

    public init(stringLiteral: String) {
        text = stringLiteral
    }

}

// MARK: CustomDebugStringConvertible
extension FunctionSignature: CustomDebugStringConvertible {

    public var debugDescription: String {
        String(reflecting: text)
    }

}
