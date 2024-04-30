//
// Created on 4/29/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// `FunctionCall` is a protocol that represents a function call in a generic way.
public protocol FunctionCall: CustomDebugStringConvertible {
    associatedtype Input
    associatedtype Output

    /// The signature of the function, that is the string that is captured by `#function`, eg. `foo(bar:)`.
    var signature: String { get }

    /// The type of the function's input parameter(s) (or `Void` if it does not take any parameters). If a function takes more than one parameter, this will be a tuple with the parameters in the order they appear in the signature.
    var input: Input { get }

    /// The return type of the function.
    var output: Output { get }

    /// The time at which the function was called.
    var time: Date { get }
}

extension FunctionCall {
    public var debugDescription: String {
        """
        signature: \(signature)
        input: \(input)
        output: \(output)
        time: \(FunctionCallUtilities.dateFormatter.string(from: time))
        """
    }
}

private enum FunctionCallUtilities {
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd H:mm:ss.SSS"
        return dateFormatter
    }()
}

/// `ConcreteFunctionCall` provides a concrete implementation of the`FunctionCall` protocol.
public struct ConcreteFunctionCall<Input, Output>: FunctionCall {

    /// The signature of the function, that is the string that is captured by `#function`, eg. `foo(bar:)`.
    public let signature: String

    /// The type of the function's input parameter(s) (or `Void` if it does not take any parameters). If a function takes more than one parameter, this will be a tuple with the parameters in the order they appear in the signature.
    public let input: Input

    /// The return type of the function.
    public let output: Output

    /// The time at which the function was called.
    public let time: Date

}
