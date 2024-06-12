//
// Created on 6/12/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

// MARK: - StubRegistry.Stub
extension StubRegistry {

    enum Stub {
        case output(Any)
        case error(Error)
        case closure(Any)

        func evaluate<Input, Output>(with input: Input = Void()) throws -> Output {
            switch self {
            case .output(let output):
                guard let output = output as? Output else {
                    throw StubError.incorrectOutputType
                }
                return output
            case .error(let error):
                throw error
            case .closure(let closure):
                guard let closure = closure as? (Input) throws -> Output else {
                    throw StubError.incorrectClosureType
                }
                return try closure(input)
            }
        }
    }

}

// MARK: - StubRegistry.Stub + CustomDebugStringConvertible
extension StubRegistry.Stub: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .output(let output):
            "stubbed output: \(output)"
        case .error(let error):
            "stubbed error: \(error)"
        case .closure:
            "stubbed using a closure"
        }
    }
}
