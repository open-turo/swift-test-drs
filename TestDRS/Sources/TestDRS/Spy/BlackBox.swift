//
// Created on 4/29/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// A mechanism to record and look up function calls for testing purposes.
public final class BlackBox {

    /// Used to make the `BlackBox` thread-safe.
    private let storageQueue = DispatchQueue(label: "BlackBoxStorageQueue")

    /// An array of function calls in the order that they were recorded.
    private var storage: [any FunctionCall] = []

    public init() {}

    /// Records a function call with the given input, output, time, and signature.
    ///
    /// - Parameters:
    ///   - input: The input parameter of the function call.
    ///   - time: The time when the function call was made.
    ///   - output: The output of the function call.
    ///   - signature: The signature of the function call.
    func recordCall<Input, Output>(
        with input: Input,
        at time: Date,
        returning output: Output,
        signature: String
    ) {
        storageQueue.async {
            self.storage.append(
                ConcreteFunctionCall(
                    signature: signature,
                    input: input,
                    output: output,
                    time: time
                )
            )
        }
    }

    /// Returns an array of function calls that match the given signature and input type.
    ///
    /// - Parameters:
    ///   - signature: The signature to match.
    ///   - previousCall: If provided, only calls occuring after the `previousCall` will be returned, otherwise all matching calls will be returned. Defaults to `nil`.
    ///   - inputType: The input type to match.
    /// - Returns: An array of function calls that match the given criteria.
    ///
    ///- Note: This method returns the function calls as an array of `[any FunctionCall]`, to instead retrieve an array of `[ConcreteFunctionCall<Input, Output>]` see `callsMatching(signature:after:taking:returning:)`.
    func callsMatching<Input>(
        signature: String,
        after previousCall: (any FunctionCall)? = nil,
        taking inputType: Input.Type = Void.self
    ) -> [any FunctionCall] {
        storageQueue.sync {
            if let previousCall {
                guard let index = storage.firstIndex(of: previousCall) else { return [] }
                return storage.dropFirst(index + 1).filter(signature: signature, inputType: inputType)
            }
            return storage.filter(signature: signature, inputType: inputType)
        }
    }

    /// Returns an array of concrete function calls that match the given signature, input type, and output type.
    ///
    /// - Parameters:
    ///   - signature: The signature to match.
    ///   - previousCall: If provided, only calls occuring after the `previousCall` will be returned, otherwise all matching calls will be returned. Defaults to `nil`.
    ///   - inputType: The input type to match.
    ///   - outputType: The output type to match.
    /// - Returns: An array of concrete function calls that match the given criteria.
    func callsMatching<Input, Output>(
        signature: String,
        after previousCall: (any FunctionCall)? = nil,
        taking inputType: Input.Type,
        returning outputType: Output.Type
    ) -> [ConcreteFunctionCall<Input, Output>] {
        storageQueue.sync {
            if let previousCall {
                guard let index = storage.firstIndex(of: previousCall) else { return [] }
                return storage.dropFirst(index + 1).filter(signature: signature).compactMap { $0 as? ConcreteFunctionCall<Input, Output> }
            }
            return storage.filter(signature: signature).compactMap {
                $0 as? ConcreteFunctionCall<Input, Output>
            }
        }
    }

    /// Returns the function call that comes after the given previous call.
    ///
    /// - Parameter previousCall: The previous function call.
    /// - Returns: The function call that comes after the given previous call, or `nil` if not found.
    func callAfter(_ previousCall: any FunctionCall) -> (any FunctionCall)? {
        storageQueue.sync {
            guard let index = storage.firstIndex(of: previousCall) else { return nil }
            return storage.elementAt(index + 1)
        }
    }

    /// Returns the first function call in the storage.
    var firstCall: (any FunctionCall)? {
        storageQueue.sync {
            storage.first
        }
    }

    /// Returns the last function call in the storage.
    var lastCall: (any FunctionCall)? {
        storageQueue.sync {
            storage.last
        }
    }
}

// MARK: CustomDebugStringConvertible
extension BlackBox: CustomDebugStringConvertible {
    public var debugDescription: String {
        storageQueue.sync {
            storage.enumerated().map { index, functionCall -> String in
                """
                ******* Function Call \(index + 1) *******
                \(functionCall)
                """
            }.joined(separator: "\n \n") // The empty newline is stripped without the space inbetween.
        }
    }
}

private extension Sequence<any FunctionCall> {
    /// Filters the sequence to include only the function calls that match the given signature.
    ///
    /// - Parameter signature: The signature to match.
    /// - Returns: An array of function calls that match the given signature.
    func filter(signature: String) -> [any FunctionCall] {
        return filter { call in
            call.signature == signature
        }
    }

    /// Filters the sequence to include only the function calls that match the given signature and input type.
    ///
    /// - Parameters:
    ///   - signature: The signature to match.
    ///   - inputType: The input type to match.
    /// - Returns: An array of function calls that match the given signature and input type.
    func filter<Input>(signature: String, inputType: Input.Type) -> [any FunctionCall] {
        return filter { call in
            call.signature == signature && (inputType == Void.self || call.input is Input)
        }
    }
}

private extension [any FunctionCall] {
    /// Returns the index of the first occurrence of the given function call.
    ///
    /// - Parameter call: The function call to find.
    /// - Returns: The index of the first occurrence of the given function call, or `nil` if not found.
    func firstIndex(of call: any FunctionCall) -> Int? {
        firstIndex(where: { $0.signature == call.signature && $0.time == call.time })
    }
}

private extension Array {
    /// Returns the element at the specified index, or `nil` if the index is out of bounds.
    ///
    /// - Parameter index: The index of the element to retrieve.
    /// - Returns: The element at the specified index, or `nil` if the index is out of bounds.
    func elementAt(_ index: Array.Index) -> Array.Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
