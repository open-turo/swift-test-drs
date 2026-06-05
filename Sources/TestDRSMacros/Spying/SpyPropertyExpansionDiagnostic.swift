//
// Created on 11/15/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics

enum SpyPropertyExpansionDiagnostic: String, DiagnosticMessage {

    case invalidType
    case immutable
    case existingAccessor
    case missingArguments

    var message: String {
        switch self {
        case .invalidType:
            "@_SpyProperty can only be applied to variable declarations"
        case .immutable:
            "@_SpyProperty can only be applied to mutable variable declarations"
        case .existingAccessor:
            "@_SpyProperty can only be applied to variables without an existing accessor block"
        case .missingArguments:
            "@_SpyProperty requires both accessor type and delegate type name arguments."
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: Self.moduleDomain, id: "\(Self.self).\(rawValue)")
    }

    var severity: DiagnosticSeverity { .error }

}
