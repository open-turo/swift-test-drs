//
// Created on 5/28/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics

enum MockPropertyExpansionDiagnostic: String, DiagnosticMessage {

    case invalidType
    case immutable
    case existingAccessor

    var message: String {
        switch self {
        case .invalidType:
            "@_MockProperty can only be applied to variable declarations"
        case .immutable:
            "@_MockProperty can only be applied to mutable variable declarations"
        case .existingAccessor:
            "@_MockProperty can only be applied to variables without an existing accessor block"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: Self.moduleDomain, id: "\(Self.self).\(rawValue)")
    }

    var severity: DiagnosticSeverity { .error }

}
