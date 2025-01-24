//
// Created on 6/25/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics

enum MockExpansionDiagnostic: String, DiagnosticMessage {

    case invalidType
    case propertyWithInitializer
    case functionWithBody

    var message: String {
        switch self {
        case .invalidType:
            "@Mock can only be applied to classes and structs"
        case .propertyWithInitializer:
            "@Mock can't be applied to types containing properties that have initializers"
        case .functionWithBody:
            "@Mock can't be applied to types containing functions that have bodies"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: Self.moduleDomain, id: "\(Self.self).\(rawValue)")
    }

    var severity: DiagnosticSeverity { .error }

}
