//
// Created on 4/9/26.
// Copyright © 2026 Turo Open Source. All rights reserved.
//

import TestDRS
import Testing

@MainActor
struct EventuallyTests {

    // MARK: - Async eventually(_:) autoclosure

    @Test
    func eventually_succeeds_whenPredicateIsImmediatelyTrue() async throws {
        try await eventually(true, timeout: 5)
    }

    @Test
    func eventually_reportsIssue_whenPredicateNeverBecomesTrue() async {
        await withKnownIssue {
            try await eventually(false, timeout: 0.1)
        }
    }

    // MARK: - Async eventually(_:) with async predicate

    @Test
    func eventuallyAsyncPredicate_succeeds_whenPredicateIsImmediatelyTrue() async throws {
        try await eventually({ true }, timeout: 5)
    }

    @Test
    func eventuallyAsyncPredicate_succeeds_whenPredicateBecomesTrue() async throws {
        let flag = Flag()

        Task {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1s
            await flag.set()
        }

        try await eventually({ await flag.value }, timeout: 5)
    }

    @Test
    func eventuallyAsyncPredicate_reportsIssue_whenPredicateNeverBecomesTrue() async {
        await withKnownIssue {
            try await eventually({ false }, timeout: 0.1)
        }
    }

    // MARK: - eventually(_:) closure variant

    @Test
    func eventuallyClosure_succeeds_whenPredicateIsTrue() async throws {
        let predicate: () -> Bool = { true }
        try await eventually(predicate, timeout: 5)
    }

    @Test
    func eventuallyClosure_reportsIssue_whenPredicateNeverBecomesTrue() async {
        await withKnownIssue {
            let predicate: () -> Bool = { false }
            try await eventually(predicate, timeout: 0.1)
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
