//
// Created on 5/1/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

/// Handles registering and retrieving stubs for functions, meant to be used with the `StubProviding` protocol.
public final class StubRegistry {

    private var stubs: [StubIdentifier: Stub] = [:]

    public init() {}

    /// Registers an output value for a given function signature.
    ///
    /// - Parameters:
    ///   - output: The output value to be returned when the registered function is called.
    ///   - function: The function for which the output value is registered.
    ///   - signature: The signature of the function.
    func register<Input, Output>(
        output: Output,
        for function: (Input) throws -> Output,
        withSignature signature: String
    ) {
        let identifier = StubIdentifier(signature: signature, inputType: Input.self, outputType: Output.self)
        stubs[identifier] = .output(output)
    }

    /// Registers an error for a given function signature.
    ///
    /// - Parameters:
    ///   - error: The error to be thrown when the registered function is called.
    ///   - function: The function for which the error is registered.
    ///   - signature: The signature of the function.
    func register<Input, Output>(
        error: Error,
        for function: (Input) throws -> Output,
        withSignature signature: String
    ) {
        let identifier = StubIdentifier(signature: signature, inputType: Input.self, outputType: Output.self)
        stubs[identifier] = .error(error)
    }

    /// Registers a closure for a given function signature.
    ///
    /// - Parameters:
    ///   - closure: The closure to be executed when the registered function is called.
    ///   - signature: The signature of the function.
    func register<Input, Output>(
        closure: @escaping (Input) throws -> Output,
        forSignature signature: String
    ) {
        let identifier = StubIdentifier(signature: signature, inputType: Input.self, outputType: Output.self)
        stubs[identifier] = .closure(closure)
    }

    /// Retrieves the output value for a given input and function signature.
    ///
    /// - Parameters:
    ///   - input: The input value for the function.
    ///   - signature: The signature of the function.
    /// - Returns: The output value for the given input and function signature.
    /// - Throws: `StubError.noStub` if no stub is registered for the given input and function signature, or any error thrown by the registered closure.
    func getOutput<Input, Output>(for input: Input, withSignature signature: String) throws -> Output {
        let identifier = StubIdentifier(signature: signature, inputType: Input.self, outputType: Output.self)

        guard let stub = stubs[identifier] else {
            throw StubError.noStub
        }

        switch stub {
        case .output(let output):
            guard let output = output as? Output else {
                throw StubError.incorrectOutputType
            }
            return output
        case .error(let error):
            throw error
        case .closure(let closure):
            guard let closure = closure as? (Input) throws -> Output else {
                throw StubError.incorrectClosureType
            }
            return try closure(input)
        }
    }
}

extension StubRegistry {

    private struct StubIdentifier: Hashable {
        let signature: String
        let inputType: String
        let outputType: String

        init(signature: String, inputType: Any.Type, outputType: Any.Type) {
            self.signature = signature
            self.inputType = String(describing: inputType.self)
            self.outputType = String(describing: outputType.self)
        }
    }

    private enum Stub {
        case output(Any)
        case error(Error)
        case closure(Any)
    }

    enum StubError: Error {
        /// There was no stub registered for the function when attempting to retrieve a stub.
        case noStub
        /// This would indicate an issue with the `StubProviding` protocol or the `StubRegistry`.
        case incorrectOutputType
        /// This would indicate an issue with the `StubProviding` protocol or the `StubRegistry`.
        case incorrectClosureType
    }

}
