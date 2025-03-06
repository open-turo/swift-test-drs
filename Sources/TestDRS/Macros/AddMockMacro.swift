//
// Created on 5/1/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

/// This macro generates a mock type based on a given protocol, class, or struct.
///
/// The generated mock type includes methods that mimic the original type's interface, allowing you to control its behavior in tests.
/// For a given type `MyType`, the generated mock type will be named `MockMyType`.
/// The mock type will conform to the `Mock` protocol, which provides stubbing and verification capabilities.
///
/// ## Mock Generation Rules:
/// - Classes will be mocked using a subclass
/// - Protocols and structs will be mocked using a separate class/struct
/// - Private members are not included in the generated mock type
/// - Final classes cannot be mocked (as they cannot be subclassed)
/// - Final members of a class cannot be mocked (as they cannot be overridden)
///
/// ## Member Handling:
/// - Mocked classes will override all non-private, non-final instance members
/// - Static members of a class will not be included in the mock as they cannot be overridden
/// - Protocol and struct mocks will include all non-private members
///
/// ## Initializer Handling:
/// - For protocols and structs, an empty initializer (`init()`) is always provided
/// - Any non-empty initializers from the original type are included but marked as deprecated to encourage using the empty initializer
/// - Class mocks do not include initializers, as they use the parent class initializers
/// - Note: None of the initializers, including inherited ones, will automatically stub any properties. Properties must be stubbed manually after initialization.
///
/// Usage:
/// ```
/// @AddMock
/// protocol MyType {
///     func myMethod()
/// }
/// ```
///
/// This will generate a `MockMyType` with the following structure:
/// ```
/// #if DEBUG
///
/// class MockMyType: MyType, Mock {
///     func myMethod() {
///         // Implementation for stubbing and spying
///     }
/// }
///
/// #endif
/// ```
///
/// - Note: The generated mock type will be wrapped in an `#if DEBUG` directive, meaning it will only be included in Debug builds.
/// This ensures that mock types are not included in production code.
/// The generated mock type is intended for use in unit tests, during development, in SwiftUI previews, etc.
@attached(peer, names: prefixed(Mock))
public macro AddMock() = #externalMacro(module: "TestDRSMacros", type: "AddMockMacro")
