//
// Created on 4/29/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// `FunctionCallRepresentation` is a protocol that represents a function call in a generic way.
/// Captures the `Input` and `Output` type information while allowing us to store an array of function calls as an `[any FunctionCallRepresentation]`.
/// - SeeAlso: `FunctionCall` which is the concrete version of a function call.
protocol FunctionCallRepresentation: CustomDebugStringConvertible, Identifiable {
    associatedtype Input
    associatedtype Output

    /// The signature of the function, that is the string that is captured by `#function`, eg. `foo(bar:)`.
    var signature: FunctionSignature { get }

    /// The type of the function's input parameter(s) (or `Void` if it does not take any parameters). If a function takes more than one parameter, this will be a tuple with the parameters in the order they appear in the signature.
    var input: Input { get }

    /// The return type of the function.
    var outputType: Output.Type { get }

    /// The time at which the function was called.
    var time: Date { get }

    /// The unique identifier for this call.
    var id: Int { get }
}

extension FunctionCallRepresentation {
    public var debugDescription: String {
        """
        ******* Function Call \(id) *******
        signature: \(signature)
        input: \(input)
        outputType: \(outputType)
        time: \(FunctionCallUtilities.dateFormatter.string(from: time))
        """
    }
}

// TODO: Move me
private enum FunctionCallUtilities {
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd H:mm:ss.SSS"
        return dateFormatter
    }()
}

/// `FunctionCall` provides a concrete implementation of the`FunctionCallRepresentation` protocol.
public struct FunctionCall<Input, Output>: FunctionCallRepresentation, @unchecked Sendable {

    /// The signature of the function, that is the string that is captured by `#function`, eg. `foo(bar:)`.
    public let signature: FunctionSignature

    /// The type of the function's input parameter(s) (or `Void` if it does not take any parameters). If a function takes more than one parameter, this will be a tuple with the parameters in the order they appear in the signature.
    public let input: Input

    /// The return type of the function.
    let outputType: Output.Type

    /// The time at which the function was called.
    let time: Date

    /// The unique identifier for this call.
    public let id: Int

}
