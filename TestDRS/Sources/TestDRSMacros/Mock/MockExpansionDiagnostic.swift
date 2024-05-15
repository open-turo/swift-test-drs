//
// Created on 5/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics

enum MockExpansionDiagnostic: String, DiagnosticMessage {

    case invalidType = "invalid type"

    var message: String {
        switch self {
        case .invalidType:
            "@Mock can only be applied to protocols, classes, and structs"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: String(describing: MockMacro.self), id: rawValue)
    }

    var severity: DiagnosticSeverity { .error }

}
