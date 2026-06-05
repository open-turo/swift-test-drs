//
// Created on 11/15/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftSyntax

/// Defines what type is being mocked/spied (protocol, class, or struct)
enum TypeBeingMocked: Equatable {
    case `protocol`
    case `class`
    case `struct`
}

/// Configuration for generating test doubles (mocks or spies)
struct TypeGenerationConfig {
    let typeBeingMocked: TypeBeingMocked
    let originalTypeName: String
    let isPublic: Bool
    let inheritsFromNSObject: Bool

    var shouldMakeMembersPublic: Bool {
        isPublic && typeBeingMocked == .protocol
    }

    var shouldOverrideMembers: Bool {
        typeBeingMocked == .class
    }

    var isGeneratingClass: Bool {
        typeBeingMocked != .struct
    }

    var shouldGenerateInits: Bool {
        typeBeingMocked != .class
    }

    var needsPublicInit: Bool {
        isPublic && typeBeingMocked != .class
    }

    var shouldMockStaticMembers: Bool {
        typeBeingMocked != .class
    }

    /// Returns the appropriate delegate type name for spy generation
    /// - Returns: "RealType" for protocols (generic parameter), concrete type for structs/classes
    var delegateTypeName: String {
        typeBeingMocked == .protocol ? "RealType" : originalTypeName
    }

    func shouldOverrideInitializer(_ initializer: InitializerDeclSyntax) -> Bool {
        guard inheritsFromNSObject else { return false }
        // Only override init() - NSObject doesn't have other designated initializers
        return initializer.signature.parameterClause.parameters.isEmpty
    }

    func shouldMockMember(member: WithModifiersSyntax) -> Bool {
        guard !member.isPrivate else { return false }
        guard !member.isFinal else { return false }
        // Allow 'class' members (which are overrideable), but not 'static' members (which aren't)
        guard !member.isStatic || member.isClassMember else { return shouldMockStaticMembers }
        return true
    }
}
