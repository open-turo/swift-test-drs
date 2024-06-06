//
// Created on 6/5/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// An opaque token that represents the state of static members for a particular test.
/// It should be held onto for the duration of a test that tests static members of a ``Mock``, ``Spy``, or ``StubProviding`` type.
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
/// let tokenStore = StaticTestingTokenStore()
///
/// override func setUp() {
///     MyType.generateStaticTestingToken()
///        .store(in: tokenStore)
///     super.setUp()
/// }
/// ```
public protocol StaticTestingToken {
    func invalidate()
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
