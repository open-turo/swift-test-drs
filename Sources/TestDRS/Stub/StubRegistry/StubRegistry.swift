//
// Created on 5/1/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

/// Handles registering and retrieving stubs for members, meant to be used with the `StubProviding` protocol.
public final class StubRegistry {

    private var functionStubs: [FunctionStubIdentifierType: Stub] = [:]
    private var propertyStubs: [String: Stub] = [:]

    private var isEmpty: Bool { functionStubs.isEmpty }

    public init() {}

    // MARK: - Registering Function Stubs

    /// Registers an output value for a given function signature.
    ///
    /// - Parameters:
    ///   - output: The output value to be returned when the registered function is called.
    ///   - function: The function for which the output value is registered.
    ///   - signature: The signature of the function.
    func register<Input, Output>(
        output: Output,
        for function: (Input) async throws -> Output,
        withSignature signature: FunctionSignature
    ) {
        let identifier = FunctionStubIdentifierType(signature: signature, inputType: Input.self, outputType: Output.self)
        functionStubs[identifier] = .output(output)
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
        withSignature signature: FunctionSignature
    ) {
        let identifier = FunctionStubIdentifierType(signature: signature, inputType: Input.self, outputType: Output.self)
        functionStubs[identifier] = .error(error)
    }

    /// Registers a closure for a given function signature.
    ///
    /// - Parameters:
    ///   - closure: The closure to be executed when the registered function is called.
    ///   - signature: The signature of the function.
    func register<Input, Output>(
        closure: @escaping (Input) throws -> Output,
        forSignature signature: FunctionSignature
    ) {
        let identifier = FunctionStubIdentifierType(signature: signature, inputType: Input.self, outputType: Output.self)
        functionStubs[identifier] = .closure(closure)
    }

    // MARK: - Registering Property Stubs

    /// Registers a value to return for a given property name.
    /// - Parameters:
    ///   - value: The value to return for the given property.
    ///   - propertyName: The name of the property that is being stubbed.
    func register(value: Any, for propertyName: String) {
        propertyStubs[propertyName] = .output(value)
    }

    // MARK: - Retrieving Function Stub Outputs

    /// Retrieves the stubbed output for the calling function based on the given input and expected output type.
    ///
    /// - Parameters:
    ///   - input: The input to the calling function.
    ///   - signature: **Do not pass in this argument**, it will automatically capture the signature of the calling function.
    ///   - stubProvidingType: The type where the stub is being retrieved.
    /// - Returns: The stubbed output for the calling function.
    ///
    /// - Precondition: A corresponding stub must be set prior to calling this function. Otherwise, a fatal error will be thrown.
    func stubOutput<Input, Output>(
        for input: Input,
        signature: FunctionSignature,
        in stubProvidingType: StubProviding.Type
    ) -> Output {
        do {
            return try getOutput(for: input, withSignature: signature)
        } catch {
            if let stubError = error as? StubRegistry.StubError {
                report(
                    stubError,
                    in: stubProvidingType,
                    signature: signature,
                    inputType: Input.self,
                    outputType: Output.self
                )
            }
            fatalError("Unexpected error getting stub for \(signature)")
        }
    }

    /// Retrieves the stubbed output for the calling function based on the given input and expected output type, allowing for potential throwing of errors.
    ///
    /// - Parameters:
    ///   - input: The input to the calling function.
    ///   - signature: **Do not pass in this argument**, it will automatically capture the signature of the calling function.
    ///   - stubProvidingType: The type where the stub is being retrieved.
    /// - Returns: The stubbed output for the calling function, provided one has been set.
    /// - Throws: Any error that has been set to be thrown for this function.
    func throwingStubOutput<Input, Output>(
        for input: Input,
        signature: FunctionSignature,
        in stubProvidingType: StubProviding.Type
    ) throws -> Output {
        do {
            return try getOutput(for: input, withSignature: signature)
        } catch let stubError as StubRegistry.StubError {
            report(
                stubError,
                in: stubProvidingType,
                signature: signature,
                inputType: Input.self,
                outputType: Output.self
            )
            fatalError("Unexpected error getting stub for \(signature)")
        }
    }

    /// Retrieves the output value for a given input and function signature.
    ///
    /// - Parameters:
    ///   - input: The input value for the function.
    ///   - signature: The signature of the function.
    /// - Returns: The output value for the given input and function signature.
    /// - Throws: `StubError.noStub` if no stub is registered for the given input and function signature, or any error thrown by the registered closure.
    private func getOutput<Input, Output>(for input: Input, withSignature signature: FunctionSignature) throws -> Output {
        let identifier = FunctionStubIdentifierType(signature: signature, inputType: Input.self, outputType: Output.self)

        // Stubs could be set with either the full signature like `foo(paramOne:)`
        // or if there is no ambiguity, they could be set with an abbreviated signature like `foo`.
        // When we go to retrieve them, we should have the full signature since it is captured by #function.
        // So first we try to retrieve using the full signature provided, and then using the abbreviated version.
        guard let stub = functionStubs[identifier] ?? functionStubs[identifier.abbreviatedIdentifier] else {
            if let void = Void() as? Output {
                return void
            }
            throw StubError.noStub
        }

        return try stub.evaluate(with: input)
    }

    // MARK: - Retrieving Property Stub Values

    /// Retrieves the stubbed output for the calling function based on the given input and expected output type.
    ///
    /// - Parameters:
    ///   - input: The input to the calling function.
    ///   - signature: **Do not pass in this argument**, it will automatically capture the signature of the calling function.
    ///   - stubProvidingType: The type where the stub is being retrieved.
    /// - Returns: The stubbed output for the calling function.
    ///
    /// - Precondition: A corresponding stub must be set prior to calling this function. Otherwise, a fatal error will be thrown.
    func stubValue<Value>(
        for propertyName: String,
        in stubProvidingType: StubProviding.Type
    ) -> Value {
        do {
            return try getValue(for: propertyName)
        } catch {
            if let stubError = error as? StubRegistry.StubError {
                report(
                    stubError,
                    in: stubProvidingType,
                    propertyName: propertyName,
                    valueType: Value.self
                )
            }
            fatalError("Unexpected error getting stub for \(propertyName)")
        }
    }

    private func getValue<Output>(for propertyName: String) throws -> Output {
        guard let stub = propertyStubs[propertyName] else {
            throw StubError.noStub
        }

        return try stub.evaluate()
    }

    // MARK: - Error Reporting

    private func report<Input, Output>(
        _ stubError: StubRegistry.StubError,
        in stubProvidingType: StubProviding.Type,
        signature: FunctionSignature,
        inputType: Input.Type,
        outputType: Output.Type
    ) {
        switch stubError {
        case .noStub:
            if isEmpty {
                fatalError("No stubs were set for this \(stubProvidingType)")
            } else {
                fatalError("No stub was found for \(signature) with input type \(Input.self) and output type \(Output.self):\(debugDescription)")
            }
        case .incorrectOutputType, .incorrectClosureType:
            fatalError("This should not happen, there must be an issue in TestDRS within the `StubProviding` protocol and/or the `StubRegistry`.")
        }
    }

    private func report<Value>(
        _ stubError: StubRegistry.StubError,
        in stubProvidingType: StubProviding.Type,
        propertyName: String,
        valueType: Value.Type
    ) {
        switch stubError {
        case .noStub:
            if isEmpty {
                fatalError("No stubs were set for this \(stubProvidingType)")
            } else {
                fatalError("No stub was found for \(propertyName) with value type \(Value.self):\(debugDescription)")
            }
        case .incorrectOutputType, .incorrectClosureType:
            fatalError("This should not happen, there must be an issue in TestDRS within the `StubProviding` protocol and/or the `StubRegistry`.")
        }
    }

}

// MARK: CustomDebugStringConvertible
extension StubRegistry: CustomDebugStringConvertible {

    public var debugDescription: String {
        let propertyStubDescriptions = propertyStubs
            .sorted(by: { $0.key < $1.key })
            .map { stub -> String in
                """
                ******* Property Stub *******
                \(String(reflecting: stub.key))
                \(String(reflecting: stub.value))
                """
            }
            .joined(separator: .emptyLine)

        let functionStubDescriptions = functionStubs
            .sorted(by: { $0.key.signature.name < $1.key.signature.name })
            .map { stub -> String in
                """
                ******* Function Stub *******
                \(String(reflecting: stub.key))
                \(String(reflecting: stub.value))
                """
            }
            .joined(separator: .emptyLine)

        return "\n" + propertyStubDescriptions + .emptyLine + functionStubDescriptions + .emptyLine
    }

}

extension String {
    // Used to separate output in the console, the space is needed so that the newline isn't stripped.
    static let emptyLine = "\n \n"
}
