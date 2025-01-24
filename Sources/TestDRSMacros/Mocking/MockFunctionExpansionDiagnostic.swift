//
// Created on 6/18/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics

enum MockFunctionExpansionDiagnostic: String, DiagnosticMessage {

    case existingBody

    var message: String {
        switch self {
        case .existingBody:
            "@_MockFunction can only be applied to function without an existing body as the function will be mocked and any existing body would just be ignored anyway."
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: Self.moduleDomain, id: "\(Self.self).\(rawValue)")
    }

    var severity: DiagnosticSeverity { .error }

}
