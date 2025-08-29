//
// Created on 8/27/25.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import TestDRS
import Testing

#if compiler(>=6.1)

@_documentation(visibility: private)
public struct _MockLoggingTrait: TestTrait, SuiteTrait, TestScoping {

    private let identifier: String

    init(identifier: String = "🏎️") {
        self.identifier = identifier
    }

    public func provideScope(for test: Test, testCase: Test.Case?, performing function: @Sendable () async throws -> Void) async throws {
        try await withMockLogging(identifier: identifier, testName: test.displayName ?? test.name) {
            try await function()
        }
    }

}

extension Trait where Self == _MockLoggingTrait {

    /// Enables TestDRS mock logging for tests with the default "🏎️" identifier.
    public static var mockLogging: Self { Self() }

    /// Enables TestDRS mock logging for tests with a custom identifier.
    /// - Parameter identifier: The emoji identifier to prefix log messages.
    public static func mockLogging(identifier: String) -> Self { Self(identifier: identifier) }

}

#endif
