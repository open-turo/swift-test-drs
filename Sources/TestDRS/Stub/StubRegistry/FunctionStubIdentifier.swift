//
// Created on 6/12/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

// MARK: - StubRegistry.FunctionStubIdentifierType
extension StubRegistry {

    struct FunctionStubIdentifierType: Hashable {
        let signature: FunctionSignature
        let inputType: String
        let outputType: String

        init(signature: FunctionSignature, inputType: Any.Type, outputType: Any.Type) {
            self.signature = signature
            self.inputType = String(describing: inputType.self)
            self.outputType = String(describing: outputType.self)
        }

        private init(signature: FunctionSignature, inputType: String, outputType: String) {
            self.signature = signature
            self.inputType = inputType
            self.outputType = outputType
        }

        var abbreviatedIdentifier: FunctionStubIdentifierType {
            let abbreviatedSignature = FunctionSignature(text: String(signature.name))
            return FunctionStubIdentifierType(signature: abbreviatedSignature, inputType: inputType, outputType: outputType)
        }
    }

}

// MARK: - StubRegistry.FunctionStubIdentifierType + CustomDebugStringConvertible
extension StubRegistry.FunctionStubIdentifierType: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        signature: \(signature)
        inputType: \(inputType)
        outputType: \(outputType)
        """
    }
}
