//
// Created on 4/1/26.
// Copyright © 2026 Turo Open Source. All rights reserved.
//

import Foundation
import IssueReporting

// MARK: - Sync Version

/// Runs the current run loop until the given predicate evaluates to true, or the timeout is reached, whichever happens first. If the timeout is reached before the closure returns true, a test failure is reported.
/// - Parameters:
///   - predicate: An autoclosure that must return true before the timeout occurs for the test to pass.
///   - timeout: The time in seconds to wait before failing the test. The default/minimum is 5 seconds, values less than this will be ignored to avoid test flakiness.
///   - fileID: The file where the failure occurs.
///   - filePath: The file where the failure occurs.
///   - line: The line number where the failure occurs.
///   - column: The column number where the failure occurs.
@available(*, noasync, message: "Use the async version when in an async context.")
public func run(
    until predicate: @autoclosure () -> Bool,
    timeout: TimeInterval = 5.0,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column
) {
    let checkInterval: TimeInterval = 0.01
    let startDate = Date()
    let endDate = startDate.addingTimeInterval(max(timeout, 5.0))

    while !predicate() {
        let checkDate = Date().addingTimeInterval(checkInterval)
        guard checkDate < endDate else {
            reportIssue(
                "Timed out waiting for expression to evaluate to true.",
                fileID: fileID,
                filePath: filePath,
                line: line,
                column: column
            )
            return
        }
        RunLoop.current.run(until: checkDate)
    }
}

/// Runs the current run loop until the given predicate evaluates to true, or the timeout is reached, whichever happens first. If the timeout is reached before the closure returns true, a test failure is reported.
/// - Parameters:
///   - predicate: A closure that must return true before the timeout occurs for the test to pass.
///   - timeout: The time in seconds to wait before failing the test. The default/minimum is 5 seconds, values less than this will be ignored to avoid test flakiness.
///   - fileID: The file where the failure occurs.
///   - filePath: The file where the failure occurs.
///   - line: The line number where the failure occurs.
///   - column: The column number where the failure occurs.
@available(*, noasync, message: "Use the async version when in an async context.")
public func runUntil(
    _ predicate: () -> Bool,
    timeout: TimeInterval = 5.0,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column
) {
    run(until: predicate(), timeout: timeout, fileID: fileID, filePath: filePath, line: line, column: column)
}

// MARK: - Async Version

/// Runs until the given predicate evaluates to true, or the timeout is reached, whichever happens first. If the timeout is reached before the closure returns true, a test failure is reported.
/// - Parameters:
///   - predicate: An autoclosure that must return true before the timeout occurs for the test to pass.
///   - timeout: The time in seconds to wait before failing the test. The default/minimum is 5 seconds, values less than this will be ignored to avoid test flakiness.
///   - fileID: The file where the failure occurs.
///   - filePath: The file where the failure occurs.
///   - line: The line number where the failure occurs.
///   - column: The column number where the failure occurs.
@MainActor
public func run(
    until predicate: @MainActor @autoclosure () -> Bool,
    timeout: TimeInterval = 5.0,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column
) async throws {
    try await withoutActuallyEscaping(predicate) { predicate in
        let checkInterval: TimeInterval = 0.01
        let confirmationTask = Task {
            while !predicate() {
                try await Task.sleep(nanoseconds: UInt64(checkInterval) * NSEC_PER_SEC)
            }
        }
        let timeoutTask = Task {
            try await Task.sleep(nanoseconds: UInt64(max(timeout, 5.0)) * NSEC_PER_SEC)
            confirmationTask.cancel()
            reportIssue(
                "Timed out waiting for expression to evaluate to true.",
                fileID: fileID,
                filePath: filePath,
                line: line,
                column: column
            )
        }

        try await confirmationTask.value
        timeoutTask.cancel()
    }
}

/// Runs until the given predicate evaluates to true, or the timeout is reached, whichever happens first. If the timeout is reached before the closure returns true, a test failure is reported.
/// - Parameters:
///   - predicate: A closure that must return true before the timeout occurs for the test to pass.
///   - timeout: The time in seconds to wait before failing the test. The default/minimum is 5 seconds, values less than this will be ignored to avoid test flakiness.
///   - fileID: The file where the failure occurs.
///   - filePath: The file where the failure occurs.
///   - line: The line number where the failure occurs.
///   - column: The column number where the failure occurs.
@MainActor
public func runUntil(
    predicate: () -> Bool,
    timeout: TimeInterval = 5.0,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column
) async throws {
    try await run(until: predicate(), timeout: timeout, fileID: fileID, filePath: filePath, line: line, column: column)
}

// MARK: - Async Version (async predicate)

/// Runs until the given *async* predicate evaluates to true, or the timeout is reached.
/// This variant lets you `await` inside the predicate, so you can check actor-isolated state.
@MainActor
public func run(
    until asyncPredicate: @escaping () async -> Bool,
    timeout: TimeInterval = 5.0,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column
) async throws {
    let checkInterval: TimeInterval = 0.01
    let confirmationTask = Task {
        while !(await asyncPredicate()) {
            try await Task.sleep(nanoseconds: UInt64(checkInterval) * NSEC_PER_SEC)
        }
    }
    let timeoutTask = Task {
        try await Task.sleep(nanoseconds: UInt64(max(timeout, 5.0)) * NSEC_PER_SEC)
        confirmationTask.cancel()
        reportIssue(
            "Timed out waiting for expression to evaluate to true.",
            fileID: fileID,
            filePath: filePath,
            line: line,
            column: column
        )
    }

    try await confirmationTask.value
    timeoutTask.cancel()
}
