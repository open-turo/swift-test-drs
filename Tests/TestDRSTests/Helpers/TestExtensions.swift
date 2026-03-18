//
// Created on 11/17/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import TestDRS

extension StubProviding {

    /// Helper method to set a property stub and return self for chaining.
    /// Example: `MockType().with(\.propertyName, value)`
    func with<T>(_ keyPath: KeyPath<Self, T>, _ value: T) -> Self {
        setStub(value: value, forPropertyNamed: "\(keyPath)".components(separatedBy: ".").last!)
        return self
    }

}
