//
// Created on 5/16/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

public extension Spy {

    /// The default static `BlackBox` for a type.
    /// Allows for a generic type to be a `Spy` since generic types can't have stored static properties.
    static var blackBox: BlackBox {
        BlackBox.blackBox(for: Self.self)
    }

}

private extension BlackBox {

    static func blackBox<T>(for type: T.Type) -> BlackBox {
        let key = String(describing: type)

        if let blackBox = blackBoxStorage[key] {
            return blackBox
        }

        let blackBox = BlackBox()
        blackBoxStorage[key] = blackBox

        return blackBox
    }

    static var blackBoxStorage: [String: BlackBox] = [:]

}
