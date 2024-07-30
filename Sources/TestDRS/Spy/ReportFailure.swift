//
// Created on 6/18/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import IssueReporting

func reportFailure(_ message: String) {
    reportIssue(message)
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
