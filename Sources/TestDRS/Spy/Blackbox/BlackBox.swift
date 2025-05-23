//
// Created on 4/29/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// A mechanism to record and look up function calls for testing purposes.
public final class BlackBox: @unchecked Sendable {

    /// Used to make the `BlackBox` thread-safe.
    private let storageQueue = DispatchQueue(label: "BlackBoxStorageQueue")

    /// An array of function calls in the order that they were recorded.
    private var storage: [any FunctionCallRepresentation] = []

    private var continuations: [any FunctionCallContinuationRepresentation] = []

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
        returning outputType: Output.Type,
        signature: FunctionSignature
    ) {
        storageQueue.sync {
            let call = FunctionCall(
                signature: signature,
                input: input,
                outputType: outputType,
                time: time,
                id: self.storage.count + 1
            )
            self.storage.append(call)

            if #available(iOS 16.0, *) {
                streamCall(call)
            }
        }
    }

    /// Returns an array of function calls that match the given signature.
    ///
    /// - Parameters:
    ///   - signature: The signature to match.
    func callsMatching<Input>(
        signature: FunctionSignature,
        taking inputType: Input.Type = Void.self
    ) -> [any FunctionCallRepresentation] {
        storageQueue.sync {
            storage.filter(signature: signature)
        }
    }

}

// MARK: - AsyncStream Support

extension BlackBox {

    /// Streams all calls with the given input and output type.
    func streamForCallsMatching<Input, Output>(
        signature: FunctionSignature,
        taking inputType: Input.Type,
        returning outputType: Output.Type
    ) -> AsyncStream<FunctionCall<Input, Output>> {
        AsyncStream(FunctionCall<Input, Output>.self) { continuation in
            addContinuation(FunctionCallContinuation(wrappedValue: continuation, signature: signature))
        }
    }

    // swiftformat:disable spaceAroundOperators

    /// Streams calls with input equal to the expected input and a matching output type.
    func streamForCallsMatching<each Input: Equatable, Output>(
        signature: FunctionSignature,
        withExpectedInput expectedInput: repeat each Input,
        returning outputType: Output.Type
    ) -> AsyncStream<FunctionCall<(repeat each Input), Output>> {
        AsyncStream(FunctionCall<(repeat each Input), Output>.self) { continuation in
            addContinuation(
                ExpectedInputFunctionCallContinuation(
                    wrappedValue: continuation,
                    signature: signature,
                    expectedInput: repeat each expectedInput
                )
            )
        }
    }

    // swiftformat:enable spaceAroundOperators

    private func addContinuation<Input, Output>(_ continuation: any FunctionCallContinuationRepresentation<Input, Output>) {
        storageQueue.sync {
            var continuation = continuation
            let id = continuation.id

            continuation.onTermination = { _ in
                self.storageQueue.sync {
                    if let index = self.continuations.firstIndex(where: { $0.id == id }) {
                        self.continuations.remove(at: index)
                    }
                }
            }

            continuations.append(continuation)

            // Yield all of the existing calls from the continuation since the
            // continuation could have been added after some calls have already been made
            storage
                .compactMap { $0 as? FunctionCall<Input, Output> }
                .forEach { continuation.yield($0) }
        }
    }

    private func streamCall<Input, Output>(_ call: FunctionCall<Input, Output>) {
        continuations
            .compactMap { $0 as? any FunctionCallContinuationRepresentation<Input, Output> }
            .forEach { $0.yield(call) }
    }

}

// MARK: CustomDebugStringConvertible
extension BlackBox: CustomDebugStringConvertible {
    public var debugDescription: String {
        storageQueue.sync {
            "\n" +
                storage.map { String(reflecting: $0) }
                .joined(separator: .emptyLine)
                + .emptyLine
        }
    }
}

extension Sequence<any FunctionCallRepresentation> {

    /// Filters the sequence to include only the function calls that match the given signature.
    ///
    /// - Parameter signature: The signature to match.
    /// - Returns: An array of function calls that match the given signature.
    func filter(signature: FunctionSignature) -> [any FunctionCallRepresentation] {
        return filter { call in
            call.signature ~= signature
        }
    }

    func compactMap<Input, Output>(
        taking inputType: Input.Type,
        returning outputType: Output.Type
    ) -> [FunctionCall<Input, Output>] {
        compactMap { call in
            if let typedCall = call as? FunctionCall<Input, Output> {
                return typedCall
            }
            if let input = call.input as? Input, call.outputType is Output.Type {
                // If we have the input type now, but didn't when recording, we can just create new FunctionCall with expected type
                // See ProtocolConstrainedNonGenericParameterTests
                return FunctionCall(
                    signature: call.signature,
                    input: input,
                    outputType: outputType,
                    time: call.time,
                    id: call.id
                )
            }

            return nil
        }
    }

}

private extension [any FunctionCallRepresentation] {
    /// Returns the index of the first occurrence of the given function call.
    ///
    /// - Parameter call: The function call to find.
    /// - Returns: The index of the first occurrence of the given function call, or `nil` if not found.
    func firstIndex(of call: any FunctionCallRepresentation) -> Int? {
        firstIndex(where: { $0.signature ~= call.signature && $0.time == call.time })
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
