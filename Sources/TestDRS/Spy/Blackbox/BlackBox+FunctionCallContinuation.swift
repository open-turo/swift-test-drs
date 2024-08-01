//
// Created on 7/30/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

extension BlackBox {

    /// A protocol representing a continuation for `FunctionCall`s.
    ///
    /// Allows for wrapping `AsyncStream`continuations in a way that we can:
    /// - Store an array of continuations with different `Input` and `Output` types
    /// - Have them be identifiable so that we can remove them from the array when they are terminated
    /// - Add additional logic around yielding values
    protocol FunctionCallContinuationRepresentation<Input, Output>: Sendable, Identifiable {

        associatedtype Input
        associatedtype Output
        typealias Termination = @Sendable (AsyncStream<FunctionCall<Input, Output>>.Continuation.Termination) -> Void

        var id: UUID { get }
        func yield(_ call: FunctionCall<Input, Output>)
        var onTermination: Termination? { get set }

    }

    struct FunctionCallContinuation<Input, Output>: FunctionCallContinuationRepresentation {

        typealias Termination = @Sendable (AsyncStream<FunctionCall<Input, Output>>.Continuation.Termination) -> Void

        let id = UUID()

        var onTermination: Termination? {
            get { wrappedValue.onTermination }
            set { wrappedValue.onTermination = newValue }
        }

        private let wrappedValue: AsyncStream<FunctionCall<Input, Output>>.Continuation
        private let signature: FunctionSignature

        init(wrappedValue: AsyncStream<FunctionCall<Input, Output>>.Continuation, signature: FunctionSignature) {
            self.wrappedValue = wrappedValue
            self.signature = signature
        }

        func yield(_ call: FunctionCall<Input, Output>) {
            guard call.signature == signature else { return }
            wrappedValue.yield(call)
        }

    }

    struct ExpectedInputFunctionCallContinuation<Input, Output>: FunctionCallContinuationRepresentation, @unchecked Sendable {

        typealias Termination = @Sendable (AsyncStream<FunctionCall<Input, Output>>.Continuation.Termination) -> Void

        let id = UUID()

        var onTermination: Termination? {
            get { wrappedValue.onTermination }
            set { wrappedValue.onTermination = newValue }
        }

        private let wrappedValue: AsyncStream<FunctionCall<Input, Output>>.Continuation
        private let signature: FunctionSignature
        private let checkExpectedInput: (Input) -> Bool

        init<each I: Equatable>(
            wrappedValue: AsyncStream<FunctionCall<Input, Output>>.Continuation,
            signature: FunctionSignature,
            expectedInput: repeat each I
        ) {
            self.wrappedValue = wrappedValue
            self.signature = signature
            checkExpectedInput = { input in
                check(repeat each expectedInput, against: input)
            }
        }

        func yield(_ call: FunctionCall<Input, Output>) {
            guard call.signature == signature, checkExpectedInput(call.input) else { return }
            wrappedValue.yield(call)
        }

    }

}
