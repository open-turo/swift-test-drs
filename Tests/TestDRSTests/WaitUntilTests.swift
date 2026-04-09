//
// Created on 4/9/26.
// Copyright © 2026 Turo Open Source. All rights reserved.
//

import TestDRS
import Testing

@MainActor
struct WaitUntilTests {

    // MARK: - Async wait(until:) autoclosure

    @Test
    func waitUntil_succeeds_whenPredicateIsImmediatelyTrue() async throws {
        try await wait(until: true, timeout: 5)
    }

    @Test
    func waitUntil_reportsIssue_whenPredicateNeverBecomesTrue() async {
        await withKnownIssue {
            try await wait(until: false, timeout: 5)
        }
    }

    // MARK: - Async wait(until:) with async predicate

    @Test
    func waitUntilAsyncPredicate_succeeds_whenPredicateIsImmediatelyTrue() async throws {
        try await wait(until: { true }, timeout: 5)
    }

    @Test
    func waitUntilAsyncPredicate_succeeds_whenPredicateBecomesTrue() async throws {
        let flag = Flag()

        Task {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1s
            await flag.set()
        }

        try await wait(until: { await flag.value }, timeout: 5)
    }

    @Test
    func waitUntilAsyncPredicate_reportsIssue_whenPredicateNeverBecomesTrue() async {
        await withKnownIssue {
            try await wait(until: { false }, timeout: 5)
        }
    }

    // MARK: - waitUntil(predicate:) closure variant

    @Test
    func waitUntilClosure_succeeds_whenPredicateIsTrue() async throws {
        try await waitUntil(predicate: { true }, timeout: 5)
    }

    @Test
    func waitUntilClosure_reportsIssue_whenPredicateNeverBecomesTrue() async {
        await withKnownIssue {
            try await waitUntil(predicate: { false }, timeout: 5)
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
