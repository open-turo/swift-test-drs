//
// Created on 6/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

public protocol StaticTestingTokenProvider {
    /// Prepares the type for static testing and returns a token that should be held for the duration of a given test and no longer.
    static func generateStaticTestingToken() -> StaticTestingToken
}

extension StubProviding {
    /// Prepares the `StubProviding` type for stubbing static members. The returned token should be held for the duration of a given test and no longer.
    ///
    /// - Note: Generating a new testing token invalidates any previously generated tokens and resets all static stubs for this type.
    ///
    /// Example usage within a test:
    /// ```
    /// func testSomeStaticMember() {
    ///     let token = MyType.generateStaticTestingToken()
    ///     #stub(MyType.foo, returning: "Hello World")
    ///
    ///     doSomethingThatShouldCallFooOnMyType()
    ///     token.invalidate() // The compiler would otherwise complain about the token being unused
    /// }
    /// ```
    ///
    /// Example usage within a the set up method of a test case (run before each individual test):
    /// ```
    /// private var staticTestingTokens: [StaticTestingToken] = []
    ///
    /// override func setUp() {
    ///     MyType.generateStaticTestingToken()
    ///        .store(in: &staticTestingTokens)
    ///     super.setUp()
    /// }
    /// ```
    public static func generateStaticTestingToken() -> StaticTestingToken {
        let stubRegistry = StubRegistry()
        register(staticStubRegistry: stubRegistry)
        return stubRegistry
    }
}

extension Spy {
    /// Prepares the `Spy` for spying on static members. The returned token should be held for the duration of a given test and no longer.
    ///
    /// - Note: Generating a new testing token invalidates any previously generated tokens and resets all static stubs and recorded static function calls for this type.
    ///
    /// Example usage within a test:
    /// ```
    /// func testSomeStaticMember() {
    ///     let token = MyType.generateStaticTestingToken()
    ///
    ///     doSomethingThatShouldCallFooOnMyType()
    ///
    ///     #assertWasCalled(MyType.foo, with "Hello World")
    ///     token.invalidate() // The compiler would otherwise complain about the token being unused
    /// }
    /// ```
    ///
    /// Example usage within a the set up method of a test case (run before each individual test):
    /// ```
    /// private var staticTestingTokens: [StaticTestingToken] = []
    ///
    /// override func setUp() {
    ///     MyType.generateStaticTestingToken()
    ///        .store(in: &staticTestingTokens)
    ///     super.setUp()
    /// }
    /// ```
    public static func generateStaticTestingToken() -> StaticTestingToken {
        let blackBox = BlackBox()
        register(staticBlackBox: blackBox)
        return blackBox
    }
}

extension Mock {
    /// Prepares the `Mock` for stubbing and spying on static members. The returned token should be held for the duration of a given test and no longer.
    ///
    /// - Note: Generating a new testing token invalidates any previously generated tokens and resets all static stubs and recorded static function calls for this type.
    ///
    /// Example usage within a test:
    /// ```
    /// func testSomeStaticMember() {
    ///     let token = MyType.generateStaticTestingToken()
    ///     #stub(MyType.foo, returning: "Hello World")
    ///
    ///     doSomethingThatShouldCallFooOnMyType()
    ///
    ///     #assertWasCalled(MyType.foo, with "Hello World")
    ///     token.invalidate() // The compiler would otherwise complain about the token being unused
    /// }
    /// ```
    ///
    /// Example usage within a the set up method of a test case (run before each individual test):
    /// ```
    /// private var staticTestingTokens: [StaticTestingToken] = []
    ///
    /// override func setUp() {
    ///     MyType.generateStaticTestingToken()
    ///        .store(in: &staticTestingTokens)
    ///     super.setUp()
    /// }
    /// ```
    public static func generateStaticTestingToken() -> StaticTestingToken {
        let blackBox = BlackBox()
        let stubRegistry = StubRegistry()

        register(staticBlackBox: blackBox)
        register(staticStubRegistry: stubRegistry)

        return [blackBox, stubRegistry]
    }
}
