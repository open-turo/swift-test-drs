//
// Created on 6/5/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// A type that both stubs the implementation of its members and spies on their access.
public protocol Mock: StubProviding, Spy, StaticTestable {}
