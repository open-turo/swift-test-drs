//
// Created on 6/12/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

// MARK: - StubRegistry.FunctionStubIdentifier
extension StubRegistry {

    struct FunctionStubIdentifier: Hashable {
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

        var abbreviatedIdentifier: FunctionStubIdentifier {
            let abbreviatedSignature = FunctionSignature(text: String(signature.name))
            return FunctionStubIdentifier(signature: abbreviatedSignature, inputType: inputType, outputType: outputType)
        }
    }

}

// MARK: - StubRegistry.FunctionStubIdentifier + CustomDebugStringConvertible
extension StubRegistry.FunctionStubIdentifier: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        signature: \(signature)
        inputType: \(inputType.asVoidIfEmptyParens())
        outputType: \(outputType.asVoidIfEmptyParens())
        """
    }
}
