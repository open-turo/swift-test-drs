//
// Created on 6/12/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

extension StubRegistry {

    // MARK: - Registering Property Stubs

    /// Registers a value to return for a given property name.
    /// - Parameters:
    ///   - value: The value to return for the given property.
    ///   - propertyName: The name of the property that is being stubbed.
    func register(value: Any, for propertyName: String) {
        setPropertyStub(stub: .output(value), for: propertyName)
    }

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
        let identifier = FunctionStubIdentifier(signature: signature, inputType: Input.self, outputType: Output.self)
        setFunctionStub(stub: .output(output), for: identifier)
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
        let identifier = FunctionStubIdentifier(signature: signature, inputType: Input.self, outputType: Output.self)
        setFunctionStub(stub: .error(error), for: identifier)
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
        let identifier = FunctionStubIdentifier(signature: signature, inputType: Input.self, outputType: Output.self)
        setFunctionStub(stub: .closure(closure), for: identifier)
    }

}
