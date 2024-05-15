//
// Created on 5/1/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

/// Handles registering and retrieving stubs for functions, meant to be used with the `StubProviding` protocol.
public final class StubRegistry {

    var isEmpty: Bool { stubs.isEmpty }

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
        for function: (Input) async throws -> Output,
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
        for function: (Input) async throws -> Output,
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

    /// Registers a value to return for a given property name.
    /// - Parameters:
    ///   - value: The value to return for the given property.
    ///   - propertyName: The name of the property that is being stubbed.
    func register<Output>(
        value: Output,
        for propertyName: String
    ) {
        let identifier = StubIdentifier(signature: propertyName, inputType: Void.self, outputType: Output.self)
        stubs[identifier] = .output(value)
    }

    /// Retrieves the stubbed output for the calling function based on the given input and expected output type.
    ///
    /// - Parameters:
    ///   - input: The input to the calling function.
    ///   - signature: **Do not pass in this argument**, it will automatically capture the signature of the calling function.
    /// - Returns: The stubbed output for the calling function.
    ///
    /// - Precondition: A corresponding stub must be set prior to calling this function. Otherwise, a fatal error will be thrown.
    func stubOutput<Input, Output>(
        for input: Input,
        signature: String
    ) -> Output {
        do {
            return try getOutput(for: input, withSignature: signature)
        } catch {
            if let stubError = error as? StubRegistry.StubError {
                report(stubError, signature: signature, input: Input.self, output: Output.self)
            }
            fatalError("Unexpected error getting stub for \(signature)")
        }
    }

    /// Retrieves the stubbed output for the calling function based on the given input and expected output type, allowing for potential throwing of errors.
    ///
    /// - Parameters:
    ///   - input: The input to the calling function.
    ///   - signature: **Do not pass in this argument**, it will automatically capture the signature of the calling function.
    /// - Returns: The stubbed output for the calling function, provided one has been set.
    /// - Throws: Any error that has been set to be thrown for this function.
    func throwingStubOutput<Input, Output>(
        for input: Input,
        signature: String
    ) throws -> Output {
        do {
            return try getOutput(for: input, withSignature: signature)
        } catch let stubError as StubRegistry.StubError {
            report(stubError, signature: signature, input: Input.self, output: Output.self)
            throw stubError
        }
    }

    /// Retrieves the output value for a given input and function signature.
    ///
    /// - Parameters:
    ///   - input: The input value for the function.
    ///   - signature: The signature of the function.
    /// - Returns: The output value for the given input and function signature.
    /// - Throws: `StubError.noStub` if no stub is registered for the given input and function signature, or any error thrown by the registered closure.
    private func getOutput<Input, Output>(for input: Input, withSignature signature: String) throws -> Output {
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

    private func report<Input, Output>(
        _ stubError: StubRegistry.StubError,
        signature: String,
        input: Input.Type,
        output: Output.Type
    ) {
        switch stubError {
        case .noStub:
            if isEmpty {
                fatalError("No stubs were set for this \(Self.self).")
            } else {
                fatalError("No stub with input `\(Input.self)` and output `\(Output.self)` was set for \(signature).\n\n\(debugDescription)")
            }
        case .incorrectOutputType, .incorrectClosureType:
            fatalError("This should not happen, there must be an issue in TestDRS within the `StubProviding` protocol and/or the `StubRegistry`.")
        }
    }

    public var debugDescription: String {
        stubs.enumerated().map { index, stub -> String in
            """
            ******* Stub \(index + 1) *******
            \(stub.key.debugDescription)
            \(stub.value.debugDescription)
            """
        }.joined(separator: "\n \n")
    }

}

extension StubRegistry {

    fileprivate struct StubIdentifier: Hashable {
        let signature: String
        let inputType: String
        let outputType: String

        init(signature: String, inputType: Any.Type, outputType: Any.Type) {
            self.signature = signature
            self.inputType = String(describing: inputType.self)
            self.outputType = String(describing: outputType.self)
        }
    }

    fileprivate enum Stub {
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

extension StubRegistry.StubIdentifier {
    public var debugDescription: String {
        """
        signature: \(signature)
        inputType: \(inputType)
        outputType: \(outputType)
        """
    }
}

extension StubRegistry.Stub {
    public var debugDescription: String {
        switch self {
        case .output(let output):
            "stubbed output: \(output)"
        case .error(let error):
            "stubbed error: \(error)"
        case .closure:
            "stubbed using a closure"
        }
    }
}
