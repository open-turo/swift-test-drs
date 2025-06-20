//
// Created on 6/18/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import IssueReporting

func reportFailure(
    _ message: String,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column
) {
    reportIssue(message, fileID: fileID, filePath: filePath, line: line, column: column)
}

func reportFailure(_ message: String, location: SourceLocation) {
    reportIssue(
        message,
        fileID: location.fileID,
        filePath: location.filePath,
        line: location.line,
        column: location.column
    )
}

/// Internal helper function for `expectCase` macro failures.
public func _expectCaseFailure<T>(
    expectedCase: String,
    actualValue: T,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column
) {
    let message = "Expected \(expectedCase), but got \(String(describing: actualValue))"
    reportFailure(message, fileID: fileID, filePath: filePath, line: line, column: column)
}
