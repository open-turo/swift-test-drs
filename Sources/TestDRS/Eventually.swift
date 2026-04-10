//
// Created on 4/1/26.
// Copyright © 2026 Turo Open Source. All rights reserved.
//

import Foundation
import IssueReporting

// MARK: - Sync Version

/// Polls the given predicate by spinning the current run loop until it evaluates to true, or the timeout is reached, whichever happens first. If the timeout is reached before the predicate returns true, a test failure is reported.
/// - Parameters:
///   - predicate: An autoclosure that must return true before the timeout occurs for the test to pass.
///   - timeout: The time in seconds to wait before failing the test. Defaults to 5 seconds.
///   - fileID: The file where the failure occurs.
///   - filePath: The file where the failure occurs.
///   - line: The line number where the failure occurs.
///   - column: The column number where the failure occurs.
@available(*, noasync, message: "Use the async version when in an async context.")
public func waitUntil(
    _ predicate: @autoclosure () -> Bool,
    timeout: TimeInterval = 5.0,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column
) {
    let checkInterval: TimeInterval = 0.01
    let startDate = Date()
    let endDate = startDate.addingTimeInterval(timeout)

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

/// Polls the given predicate by spinning the current run loop until it evaluates to true, or the timeout is reached, whichever happens first. If the timeout is reached before the predicate returns true, a test failure is reported.
/// - Parameters:
///   - predicate: A closure that must return true before the timeout occurs for the test to pass.
///   - timeout: The time in seconds to wait before failing the test. Defaults to 5 seconds.
///   - fileID: The file where the failure occurs.
///   - filePath: The file where the failure occurs.
///   - line: The line number where the failure occurs.
///   - column: The column number where the failure occurs.
@available(*, noasync, message: "Use the async version when in an async context.")
public func waitUntil(
    _ predicate: () -> Bool,
    timeout: TimeInterval = 5.0,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column
) {
    waitUntil(predicate(), timeout: timeout, fileID: fileID, filePath: filePath, line: line, column: column)
}

// MARK: - Async Version

/// Polls the given predicate until it evaluates to true, or the timeout is reached, whichever happens first. If the timeout is reached before the predicate returns true, a test failure is reported.
/// - Parameters:
///   - predicate: An autoclosure that must return true before the timeout occurs for the test to pass.
///   - timeout: The time in seconds to wait before failing the test. Defaults to 5 seconds.
///   - fileID: The file where the failure occurs.
///   - filePath: The file where the failure occurs.
///   - line: The line number where the failure occurs.
///   - column: The column number where the failure occurs.
@MainActor
public func until(
    _ predicate: @MainActor @autoclosure () -> Bool,
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
            try await Task.sleep(nanoseconds: UInt64(timeout) * NSEC_PER_SEC)
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

/// Polls the given predicate until it evaluates to true, or the timeout is reached, whichever happens first. If the timeout is reached before the predicate returns true, a test failure is reported.
/// - Parameters:
///   - predicate: A closure that must return true before the timeout occurs for the test to pass.
///   - timeout: The time in seconds to wait before failing the test. Defaults to 5 seconds.
///   - fileID: The file where the failure occurs.
///   - filePath: The file where the failure occurs.
///   - line: The line number where the failure occurs.
///   - column: The column number where the failure occurs.
@MainActor
public func until(
    _ predicate: () -> Bool,
    timeout: TimeInterval = 5.0,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column
) async throws {
    try await until(predicate(), timeout: timeout, fileID: fileID, filePath: filePath, line: line, column: column)
}

// MARK: - Async Version (async predicate)

/// Polls the given *async* predicate until it evaluates to true, or the timeout is reached.
/// This variant lets you `await` inside the predicate, so you can check actor-isolated state.
@MainActor
public func until(
    _ asyncPredicate: @escaping () async -> Bool,
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
        try await Task.sleep(nanoseconds: UInt64(timeout) * NSEC_PER_SEC)
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
