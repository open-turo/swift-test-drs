//
// Created on 5/16/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

// These extensions provide default `BlackBox` storage for types conforming to `Spy`.
// Swift does not allow generic types to have stored static properties, so a separate storage mechanism is needed.
// Extending `Hashable` and `Identifiable` types to be a `Spy` is also enabled by providing a unique `BlackBox`
// for each instance of a type conforming to one of those protocols.

public extension Spy {

    /// The default static `BlackBox` for a type.
    static var blackBox: BlackBox {
        BlackBox.blackBox(for: StorageKey(type: Self.self))
    }

}

public extension Spy where Self: Hashable {

    /// The default `BlackBox` for instances of types that are `Hashable`, allows for extending a hashable type to be a `Spy`.
    var blackBox: BlackBox {
        BlackBox.blackBox(
            for: StorageKey(type: Self.self, hashable: self)
        )
    }

}

public extension Spy where Self: Identifiable {

    /// The default `BlackBox` for instances of types that are `Identifiable`, allows for extending an identifiable type to be a `Spy`.
    var blackBox: BlackBox {
        BlackBox.blackBox(
            for: StorageKey(type: Self.self, hashable: id)
        )
    }

}

private extension BlackBox {

    static func blackBox(for key: StorageKey) -> BlackBox {
        if let blackBox = blackBoxStorage[key] {
            return blackBox
        }

        let blackBox = BlackBox()
        blackBoxStorage[key] = blackBox

        return blackBox
    }

    static var blackBoxStorage: [StorageKey: BlackBox] = [:]

}

struct StorageKey: Hashable {

    let typeName: String
    let hashable: AnyHashable?

    init<T>(type: T, hashable: AnyHashable? = nil) {
        typeName = "\(T.self)"
        self.hashable = hashable
    }

}
