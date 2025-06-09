//
// Created on 6/6/25.
// Copyright © 2025 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics
import SwiftSyntax

enum ExpectCaseExpansionDiagnostic: String, DiagnosticMessage {

    case invalidCasePattern

    var message: String {
        switch self {
        case .invalidCasePattern:
            return "#expectCase requires the first argument to be a case pattern (e.g., .caseName)"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: Self.moduleDomain, id: "\(Self.self).\(rawValue)")
    }

    var severity: DiagnosticSeverity { .error }
}
