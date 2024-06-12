//
// Created on 5/15/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics

extension DiagnosticMessage {
    static var moduleDomain: String { #fileID.components(separatedBy: "/").first! }
}
