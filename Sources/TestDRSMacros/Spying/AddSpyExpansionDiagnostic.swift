//
// Created on 11/17/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics

enum AddSpyExpansionDiagnostic: String, DiagnosticMessage {

    case invalidType
    case finalClass
    case actorConstrained

    var message: String {
        switch self {
        case .invalidType:
            "@AddSpy can only be applied to protocols, classes, and structs"
        case .finalClass:
            "@AddSpy can't be applied to final classes as they can not be subclassed to produce a spy."
        case .actorConstrained:
            "@AddSpy can't be applied to actor-constrained protocols. Consider using a more general constraint like Sendable to allow for class-based spies."
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: Self.moduleDomain, id: "\(Self.self).\(rawValue)")
    }

    var severity: DiagnosticSeverity { .error }

}
