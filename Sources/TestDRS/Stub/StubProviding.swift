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
public protocol StubProviding: StaticTestable {
    var stubRegistry: StubRegistry { get }
}

// MARK: - Instance methods

public extension StubProviding {

    // MARK: - Set

    /// Sets a stub for a given function to return a provided output.
    ///
    /// - Parameters:
    ///   - function: The function to stub.
    ///   - signature: The signature of the function to stub, which can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - output: The output value to be returned when the function is called.
    func setStub<Input, Output>(
        for function: (Input) async throws -> Output,
        withSignature signature: FunctionSignature,
        taking inputType: Input.Type? = nil,
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
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - error: The error to be thrown when the function is called.
    func setStub<Input, Output>(
        for function: (Input) async throws -> Output,
        withSignature signature: FunctionSignature,
        taking inputType: Input.Type? = nil,
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
        withSignature signature: FunctionSignature,
        using closure: @escaping (Input) throws -> Output
    ) {
        stubRegistry.register(closure: closure, forSignature: signature)
    }

    /// Sets a stub for a given property to return a provided output.
    ///
    /// - Parameters:
    ///   - value: The value to return.
    ///   - propertyName: The name of the property to stub as a `String`.
    func setStub(
        value: Any,
        forPropertyNamed propertyName: String
    ) {
        stubRegistry.register(value: value, for: propertyName)
    }

    /// Sets a stub for a given property to return a provided output.
    /// Meant to be called from the setter of the property, will automatically record the property name.
    ///
    /// - Parameters:
    ///   - value: The value to return.
    ///   - propertyName: **Do not pass in this argument**, it will automatically capture the name of the calling property.
    func setStub(
        value: Any,
        forPropertyNamed propertyName: StaticString = #function
    ) {
        stubRegistry.register(value: value, for: String(describing: propertyName))
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
        signature: FunctionSignature = #function
    ) -> Output {
        stubRegistry.stubOutput(for: input, signature: signature, in: Self.self)
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
        signature: FunctionSignature = #function
    ) throws -> Output {
        try stubRegistry.throwingStubOutput(for: input, signature: signature, in: Self.self)
    }

    func stubValue<Output>(for propertyName: String = #function) -> Output {
        stubRegistry.stubValue(for: propertyName, in: Self.self)
    }

}

// TODO: The static versions of each method could be generated by a macro.

// MARK: - Static methods

public extension StubProviding {

    // MARK: - Set

    /// Sets a stub for a given function to return a provided output.
    ///
    /// - Parameters:
    ///   - function: The function to stub.
    ///   - signature: The signature of the function to stub, which can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - output: The output value to be returned when the function is called.
    static func setStub<Input, Output>(
        for function: (Input) async throws -> Output,
        withSignature signature: FunctionSignature,
        taking inputType: Input.Type? = nil,
        returning output: Output
    ) {
        getStaticStubRegistry().register(output: output, for: function, withSignature: signature)
    }

    /// Sets a stub for a given function to throw a provided error.
    ///
    /// - Parameters:
    ///   - function: The function to stub.
    ///   - signature: The signature of the function to stub, which can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - error: The error to be thrown when the function is called.
    static func setStub<Input, Output>(
        for function: (Input) async throws -> Output,
        withSignature signature: FunctionSignature,
        taking inputType: Input.Type? = nil,
        throwing error: Error
    ) {
        getStaticStubRegistry().register(error: error, for: function, withSignature: signature)
    }

    /// Sets a stub for a given function using a closure to dynamically determine the output.
    ///
    /// - Parameters:
    ///   - function: The function to stub.
    ///   - signature: The signature of the function to stub, which can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - closure: A closure that takes in the function's input and returns the desired output when the function is called.
    static func setDynamicStub<Input, Output>(
        for function: (Input) async throws -> Output,
        withSignature signature: FunctionSignature,
        using closure: @escaping (Input) throws -> Output
    ) {
        getStaticStubRegistry().register(closure: closure, forSignature: signature)
    }

    /// Sets a stub for a given property to return a provided output.
    ///
    /// - Parameters:
    ///   - value: The value to return.
    ///   - propertyName: The name of the property to stub as a `String`.
    static func setStub<Output>(
        value: Output,
        forPropertyNamed propertyName: String
    ) {
        getStaticStubRegistry().register(value: value, for: propertyName)
    }

    /// Sets a stub for a given property to return a provided output.
    /// Meant to be called from the setter of the property, will automatically record the property name.
    ///
    /// - Parameters:
    ///   - value: The value to return.
    ///   - propertyName: **Do not pass in this argument**, it will automatically capture the name of the calling property.
    static func setStub<Output>(
        value: Output,
        forPropertyNamed propertyName: StaticString = #function
    ) {
        getStaticStubRegistry().register(value: value, for: String(describing: propertyName))
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
    static func stubOutput<Input, Output>(
        for input: Input = Void(),
        signature: FunctionSignature = #function
    ) -> Output {
        getStaticStubRegistry().stubOutput(for: input, signature: signature, in: Self.self)
    }

    /// Retrieves the stubbed output for the calling function based on the given input and expected output type, allowing for potential throwing of errors.
    ///
    /// - Parameters:
    ///   - input: The input to the calling function.
    ///   - signature: **Do not pass in this argument**, it will automatically capture the signature of the calling function.
    /// - Returns: The stubbed output for the calling function, provided one has been set.
    /// - Throws: Any error that has been set to be thrown for this function.
    static func throwingStubOutput<Input, Output>(
        for input: Input = Void(),
        signature: FunctionSignature = #function
    ) throws -> Output {
        try getStaticStubRegistry().throwingStubOutput(for: input, signature: signature, in: Self.self)
    }

    static func stubValue<Output>(for propertyName: String = #function) -> Output {
        getStaticStubRegistry().stubValue(for: propertyName, in: Self.self)
    }

}
