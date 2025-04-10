//
// Created on 5/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics

enum AddMockExpansionDiagnostic: String, DiagnosticMessage {

    case invalidType
    case finalClass
    case actorConstrained

    var message: String {
        switch self {
        case .invalidType:
            "@AddMock can only be applied to protocols, classes, and structs"
        case .finalClass:
            "@AddMock can't be applied to final classes as they can not be subclassed to produce a mock."
        case .actorConstrained:
            "@AddMock can't be applied to actor-constrained protocols. Consider using a more general constraint like Sendable to allow for class-based mocks."
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: Self.moduleDomain, id: "\(Self.self).\(rawValue)")
    }

    var severity: DiagnosticSeverity { .error }

}
