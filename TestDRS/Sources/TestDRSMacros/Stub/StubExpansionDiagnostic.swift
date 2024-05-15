//
// Created on 5/8/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics
import SwiftSyntaxMacros

struct StubExpansionDiagnostic: DiagnosticMessage {

    let issue: Issue
    let macro: ExpressionMacro.Type

    var message: String {
        switch issue {
        case .missingArgument(let argumentLabel):
            "Missing argument named `\(argumentLabel)` when attempting to expand \(macro)"
        case .unableToResolveMember:
            "Unable to resolve member to stub when attempting to expand \(macro)"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: Self.moduleDomain, id: "\(Self.self).\(issue)")
    }

    var severity: DiagnosticSeverity { .error }

}

// MARK: StubExpansionDiagnostic.Issue
extension StubExpansionDiagnostic {

    enum Issue: CustomDebugStringConvertible {
        case missingArgument(labeled: String)
        case unableToResolveMember

        var debugDescription: String {
            switch self {
            case .missingArgument:
                "missingArgument"
            case .unableToResolveMember:
                "unableToResolveMember"
            }
        }
    }

}
