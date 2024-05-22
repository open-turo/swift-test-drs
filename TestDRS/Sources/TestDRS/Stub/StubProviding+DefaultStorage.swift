//
// Created on 5/16/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

// These extensions provide default `StubRegistry` storage for types conforming to `StubProviding`.
// Swift does not allow generic types to have stored static properties, so a separate storage mechanism is needed.
// Extending `Hashable` and `Identifiable` types to be `StubProviding` is also enabled by providing a unique `StubRegistry`
// for each instance of a type conforming to one of those protocols.

public extension StubProviding {

    /// The default static `StubRegistry` for a type.
    static var stubRegistry: StubRegistry {
        StubRegistry.stubRegistry(for: StorageKey(type: Self.self))
    }

}

public extension StubProviding where Self: Hashable {

    /// The default `BlackBox` for instances of types that are `Hashable`, allows for extending a hashable type to be a `Spy`.
    var stubRegistry: StubRegistry {
        StubRegistry.stubRegistry(
            for: StorageKey(type: Self.self, hashable: self)
        )
    }

}

public extension StubProviding where Self: Identifiable {

    /// The default `BlackBox` for instances of types that are `Identifiable`, allows for extending an identifiable type to be a `Spy`.
    var stubRegistry: StubRegistry {
        StubRegistry.stubRegistry(
            for: StorageKey(type: Self.self, hashable: id)
        )
    }

}

private extension StubRegistry {

    static func stubRegistry(for key: StorageKey) -> StubRegistry {
        if let stubRegistry = stubRegistryStorage[key] {
            return stubRegistry
        }

        let stubRegistry = StubRegistry()
        stubRegistryStorage[key] = stubRegistry

        return stubRegistry
    }

    private static var stubRegistryStorage: [StorageKey: StubRegistry] = [:]

}
