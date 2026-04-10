//
// Created on 4/9/26.
// Copyright © 2026 Turo Open Source. All rights reserved.
//

import TestDRS
import Testing

@MainActor
struct WaitUntilTests {

    // MARK: - Async until(_:) autoclosure

    @Test
    func until_succeeds_whenPredicateIsImmediatelyTrue() async throws {
        try await until(true, timeout: 5)
    }

    @Test
    func until_reportsIssue_whenPredicateNeverBecomesTrue() async {
        await withKnownIssue {
            try await until(false, timeout: 0.1)
        }
    }

    // MARK: - Async until(_:) with async predicate

    @Test
    func untilAsyncPredicate_succeeds_whenPredicateIsImmediatelyTrue() async throws {
        try await until({ true }, timeout: 5)
    }

    @Test
    func untilAsyncPredicate_succeeds_whenPredicateBecomesTrue() async throws {
        let flag = Flag()

        Task {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1s
            await flag.set()
        }

        try await until({ await flag.value }, timeout: 5)
    }

    @Test
    func untilAsyncPredicate_reportsIssue_whenPredicateNeverBecomesTrue() async {
        await withKnownIssue {
            try await until({ false }, timeout: 0.1)
        }
    }

    // MARK: - until(_:) closure variant

    @Test
    func untilClosure_succeeds_whenPredicateIsTrue() async throws {
        let predicate: () -> Bool = { true }
        try await until(predicate, timeout: 5)
    }

    @Test
    func untilClosure_reportsIssue_whenPredicateNeverBecomesTrue() async {
        await withKnownIssue {
            let predicate: () -> Bool = { false }
            try await until(predicate, timeout: 0.1)
        }
    }
}

// MARK: - Helpers

@MainActor
private final class Flag {
    var value = false

    func set() {
        value = true
    }
}
