//
// Created on 5/17/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntaxMacros

struct ExpectationExpansionDiagnostic: DiagnosticMessage {

    let issue: Issue
    let macro: ExpressionMacro.Type

    var message: String {
        switch issue {
        case .unableToResolveFunction:
            "Unable to resolve function when attempting to expand \(macro)"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: Self.moduleDomain, id: "\(Self.self).\(issue)")
    }

    var severity: DiagnosticSeverity { .error }

}

// MARK: ExpectationExpansionDiagnostic.Issue
extension ExpectationExpansionDiagnostic {

    enum Issue: String {
        case unableToResolveFunction
    }

}
