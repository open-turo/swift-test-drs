//
// Created on 5/2/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftSyntax

extension FunctionDeclSyntax {

    /// Returns `DeclReferenceExprSyntax` representing the input parameters of the function.
    /// No parameters are represented by empty parentheses which is the same as `Void()`.
    /// Multiple parameters are represented by a tuple.
    var inputParameters: DeclReferenceExprSyntax {
        let inputParameters: String

        if signature.parameterClause.parameters.count == 1 {
            inputParameters = "\(signature.parameterClause.parameters.first!.internalName)"
        } else {
            let parameters = signature.parameterClause.parameters.map { $0.internalName.trimmedDescription }
            inputParameters = "(\(parameters.joined(separator: ", ")))"
        }

        return DeclReferenceExprSyntax(baseName: .identifier(inputParameters))
    }

    var isThrowing: Bool {
        signature.effectSpecifiers?.throwsSpecifier != nil
    }

    var hasParameters: Bool { !signature.parameterClause.parameters.isEmpty }

}
