//
// Created on 3/6/25.
// Copyright © 2025 Turo Open Source. All rights reserved.
//

import Foundation
import TestDRS
import Testing

// Verifying that the mocks are generated properly by lack of build errors.

@Mock
public struct SomePublicMockStruct: SomePublicProtocol {
    public var id: UUID
    public var x: String
    public var y: Int

    public static var z: Bool

    public init() {}

    public init(x: String, y: Int) {
        self.x = x
        self.y = y
    }

    public func foo()
    public func bar(paramOne: Int)
    public func baz<T>(paramOne: Bool, paramTwo: T) -> T
    public func bam() throws
    public static func oof() -> String
}

@Mock
public class SomePublicMockClass: SomePublicProtocol, @unchecked Sendable {
    public var id: UUID
    public var x: String
    public var y: Int

    public static var z: Bool

    public init() {}

    public required init(x: String, y: Int) {
        self.x = x
        self.y = y
    }

    public func foo()
    public func bar(paramOne: Int)
    public func baz<T>(paramOne: Bool, paramTwo: T) -> T
    public func bam() throws
    public static func oof() -> String
}
