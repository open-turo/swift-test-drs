//
// Created on 5/16/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

public extension StubProviding {

    /// The default static `StubRegistry` for a type.
    /// Allows for a generic type to be `StubProviding` since generic types can't have stored static properties.
    static var stubRegistry: StubRegistry {
        StubRegistry.stubRegistry(for: Self.self)
    }

}

private extension StubRegistry {

    static func stubRegistry<T>(for type: T.Type) -> StubRegistry {
        let key = String(describing: type)

        if let stubRegistry = stubRegistryStorage[key] {
            return stubRegistry
        }

        let stubRegistry = StubRegistry()
        stubRegistryStorage[key] = stubRegistry

        return stubRegistry
    }

    private static var stubRegistryStorage: [String: StubRegistry] = [:]

}
