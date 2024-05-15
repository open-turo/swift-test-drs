//
// Created on 5/8/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics

enum StubExpansionDiagnostic: String, DiagnosticMessage {

    case unknown

    var message: String {
        switch self {
        case .unknown:
            "Unknown error expanding #stub macro"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: Self.moduleDomain, id: "\(String(describing: Self.self)).\(rawValue)")
    }

    var severity: DiagnosticSeverity { .error }

}
