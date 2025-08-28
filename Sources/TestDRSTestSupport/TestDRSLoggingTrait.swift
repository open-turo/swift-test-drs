//
// Created on 8/27/25.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import TestDRS
import Testing

#if compiler(>=6.1)

@_documentation(visibility: private)
public struct _TestDRSLoggingTrait: TestTrait, SuiteTrait, TestScoping {

    private let identifier: String

    init(identifier: String = "🏎️") {
        self.identifier = identifier
    }

    public func provideScope(for test: Test, testCase: Test.Case?, performing function: @Sendable () async throws -> Void) async throws {
        try await withTestDRSLogging(identifier: identifier, testName: test.displayName ?? test.name) {
            try await function()
        }
    }

}

extension Trait where Self == _TestDRSLoggingTrait {

    public static var testDRSLogging: Self { Self() }

    public static func testDRSLogging(identifier: String) -> Self { Self(identifier: identifier) }

}

#endif
