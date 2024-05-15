//
// Created on 5/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics

enum MockExpansionDiagnostic: String, DiagnosticMessage {

    case invalidType

    var message: String {
        switch self {
        case .invalidType:
            "@Mock can only be applied to protocols, classes, and structs"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: Self.moduleDomain, id: "\(Self.self).\(rawValue)")
    }

    var severity: DiagnosticSeverity { .error }

}
