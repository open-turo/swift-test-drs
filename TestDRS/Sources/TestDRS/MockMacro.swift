//
// Created on 5/1/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

/// This macro generates a mock type based on a given protocol, class, or struct.
///
/// The generated mock type includes methods that mimic the original type's interface, allowing you to control its behavior in tests.
/// For a given type `MyType`, the generated mock type will be named `MockMyType`.
/// The mock type will conform to the `StubProviding` and `Spy` protocols. This allows you to stub out each method and assert that methods were called in your tests.
/// Classes will be mocked using a subclass, while protocols and structs will be mocked using a separate class.
/// Private members are not included in the generated mock type.
/// Static members of a class will not be included in the generated mock type as they cannot be overridden.
///
/// Usage:
/// ```
/// @Mock
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
public macro Mock() = #externalMacro(module: "TestDRSMacros", type: "MockMacro")
