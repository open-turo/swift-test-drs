//
// Created on 5/1/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// `StubProviding` is a protocol that defines a stubbing mechanism for unit testing.
/// It allows you to replace real method calls with stubbed responses, making it easier to test your code in isolation.
/// Each stub is associated with the function's signature, input type, and output type.
/// This information is used to retrieve the stub when the function is called.
///
/// Example usage:
/// ```
/// class MyClass: StubProviding {
///     let stubRegistry = StubRegistry()
///
///     func foo() -> Int {
///         stubOutput()
///     }
/// }
///
/// let myClass = MyClass()
/// myClass.setStub(for: myClass.foo, withSignature: "foo()", returning: 42)
/// print(myClass.foo())  // Prints "42"
/// ```
public protocol StubProviding {
    var stubRegistry: StubRegistry { get }
}

public extension StubProviding {

    // MARK: - Set

    /// Sets a stub for a given function to return a provided output.
    ///
    /// - Parameters:
    ///   - function: The function to stub.
    ///   - signature: The signature of the function to stub, which can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - output: The output value to be returned when the function is called.
    ///
    ///   - Note: The compiler will not be able to disambiguate when stubbing functions that are overloaded *and* share the same output type.
    ///   If that is the case, use `setDynamicStub(for:withSignature:using:)` and specify the input to the closure explicitly.
    func setStub<Input, Output>(
        for function: (Input) async throws -> Output,
        withSignature signature: String,
        returning output: Output
    ) {
        stubRegistry.register(output: output, for: function, withSignature: signature)
    }

    /// Sets a stub for a given function to throw a provided error.
    ///
    /// - Parameters:
    ///   - function: The function to stub.
    ///   - signature: The signature of the function to stub, which can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - error: The error to be thrown when the function is called.
    ///
    ///   - Note: The compiler will not be able to disambiguate when stubbing functions that are overloaded *and* share the same output type.
    ///   If that is the case, use `setDynamicStub(for:withSignature:using:)` and specify the input to the closure explicitly.
    func setStub<Input, Output>(
        for function: (Input) async throws -> Output,
        withSignature signature: String,
        throwing error: Error
    ) {
        stubRegistry.register(error: error, for: function, withSignature: signature)
    }

    /// Sets a stub for a given function using a closure to dynamically determine the output.
    ///
    /// - Parameters:
    ///   - function: The function to stub.
    ///   - signature: The signature of the function to stub, which can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - closure: A closure that takes in the function's input and returns the desired output when the function is called.
    func setDynamicStub<Input, Output>(
        for function: (Input) async throws -> Output,
        withSignature signature: String,
        using closure: @escaping (Input) throws -> Output
    ) {
        stubRegistry.register(closure: closure, forSignature: signature)
    }

    // MARK: - Get

    /// Retrieves the stubbed output for the calling function based on the given input and expected output type.
    ///
    /// - Parameters:
    ///   - input: The input to the calling function.
    ///   - signature: **Do not pass in this argument**, it will automatically capture the signature of the calling function.
    /// - Returns: The stubbed output for the calling function.
    ///
    /// - Precondition: A corresponding stub must be set prior to calling this function. Otherwise, a fatal error will be thrown.
    func stubOutput<Input, Output>(
        for input: Input = Void(),
        signature: String = #function
    ) -> Output {
        do {
            return try stubRegistry.getOutput(for: input, withSignature: signature)
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
        for input: Input = Void(),
        signature: String = #function
    ) throws -> Output {
        do {
            return try stubRegistry.getOutput(for: input, withSignature: signature)
        } catch let stubError as StubRegistry.StubError {
            report(stubError, signature: signature, input: Input.self, output: Output.self)
            throw stubError
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
            if stubRegistry.isEmpty {
                fatalError("No stubs were set for this \(Self.self).")
            } else {
                fatalError("No stub with input `\(Input.self)` and output `\(Output.self)` was set for \(signature).\n\n\(stubRegistry.debugDescription)")
            }
        case .incorrectOutputType, .incorrectClosureType:
            fatalError("This should not happen, there must be an issue in TestDRS within the `StubProviding` protocol and/or the `StubRegistry`.")
        }
    }

}
