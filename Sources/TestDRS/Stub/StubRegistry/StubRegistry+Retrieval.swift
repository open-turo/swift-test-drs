//
// Created on 6/12/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

extension StubRegistry {

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
