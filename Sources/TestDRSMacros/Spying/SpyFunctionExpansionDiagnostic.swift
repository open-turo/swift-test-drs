//
// Created on 11/15/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics

enum SpyFunctionExpansionDiagnostic: String, DiagnosticMessage {

    case existingBody
    case missingDelegateTypeName

    var message: String {
        switch self {
        case .existingBody:
            "@_SpyFunction can only be applied to function without an existing body as the function will be spied and any existing body would just be ignored anyway."
        case .missingDelegateTypeName:
            "@_SpyFunction requires a delegate type name argument."
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: Self.moduleDomain, id: "\(Self.self).\(rawValue)")
    }

    var severity: DiagnosticSeverity { .error }

}
