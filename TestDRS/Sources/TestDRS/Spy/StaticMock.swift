//
// Created on 5/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// `StaticMock` is a struct that conforms to both `Spy` and `StubProviding` protocols.
/// It is used as a wrapper around these protocols to avoid the need to replicate all of their instance methods in static versions.
/// This allows us to stub and spy on static members.
///
/// Example usage:
/// ```
/// struct MockSomeStruct: Spy, StubProviding {
///
///     static let staticMock = StaticMock()
///
///     static var foo {
///         get {
///             staticMock.stubOutput()
///         }
///         set {
///             staticMock.setStub(value: newValue)
///         }
///     }
///
///     static func bar(paramOne: String) -> Int {
///         let callTime = Date()
///         return staticMock.recordCall(
///             with: paramOne,
///             at: callTime,
///             returning: staticMock.stubOutput(for: paramOne)
///         )
///     }
///
///}
/// ```
public struct StaticMock: Spy, StubProviding {
    public let blackBox = BlackBox()
    public let stubRegistry = StubRegistry()

    public init() {}
}
