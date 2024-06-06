//
// Created on 6/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// An opaque storage for `StaticTestingToken`s, used with `StaticTestingToken.store(in:)` to store `StaticTestingToken`s.
///
/// Example usage within a the set up method of a test case:
/// ```
/// private let tokenStore = StaticTestingTokenStore()
///
/// override func setUp() {
///     MyType.generateStaticTestingToken()
///        .store(in: tokenStore)
///     MyOtherType.generateStaticTestingToken()
///        .store(in: tokenStore)
///     super.setUp()
/// }
/// ```
public class StaticTestingTokenStore {
    private var storage: [StaticTestingToken] = []

    func append(_ token: StaticTestingToken) {
        storage.append(token)
    }
}

extension StaticTestingToken {
    /// Stores this token in the given token store.
    func store(in tokenStore: StaticTestingTokenStore) {
        tokenStore.append(self)
    }
}
