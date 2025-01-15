//
// Created on 5/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics

enum AddMockExpansionDiagnostic: String, DiagnosticMessage {

    case invalidType
    case finalClass

    var message: String {
        switch self {
        case .invalidType:
            "@AddMock can only be applied to protocols, classes, and structs"
        case .finalClass:
            "@AddMock can't be applied to final classes as they can not be subclassed to produce a mock."
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: Self.moduleDomain, id: "\(Self.self).\(rawValue)")
    }

    var severity: DiagnosticSeverity { .error }

}
