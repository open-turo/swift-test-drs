//
// Created on 6/5/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// An opaque token that represents the state of static members for a particular test.
/// It should be held onto for the duration of a test that tests static members of a ``Mock``, ``Spy``, or ``StubProviding`` type.
/// Tokens are automatically invalidated when you no longer maintain a reference to them.
///
/// Testing static members can be challenging because they maintain their state across tests.
/// This can lead to side effects where the outcome of one test affects another, leading to flaky tests that pass or fail unpredictably.
/// Generating a `StaticTestingToken` for a given type before each test ensures that it starts with a clean slate and does not have a dependency on other tests.
///
/// Example usage within a test:
/// ```
/// func testExample() {
///     let token = MyType.generateStaticTestingToken()
///     // Perform test with MyType...
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
public protocol StaticTestingToken {
    /// Manually invalidates a token.
    /// Tokens are also automatically invalidated when you no longer maintain a reference to them,
    /// or when you generate a new token for a given type.
    func invalidate()
}

extension StaticTestingToken {
    /// Stores this token in the specified collection.
    /// - Parameter collection: The collection in which to store this ``StaticTestingToken``.
    func store<C>(in collection: inout C) where C: RangeReplaceableCollection, C.Element == StaticTestingToken {
        collection.append(self)
    }
}

// MARK: - BlackBox + StaticTestingToken
extension BlackBox: StaticTestingToken {
    public func invalidate() {
        BlackBox.invalidate(staticStorage: self)
    }
}

// MARK: - StubRegistry + StaticTestingToken
extension StubRegistry: StaticTestingToken {
    public func invalidate() {
        StubRegistry.invalidate(staticStorage: self)
    }
}

// MARK: - StaticTestingToken + StaticTestingToken
extension [StaticTestingToken]: StaticTestingToken {
    public func invalidate() {
        forEach { $0.invalidate() }
    }
}
