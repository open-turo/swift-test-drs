//
// Created on 5/1/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// Handles registering and retrieving stubs for members, meant to be used with the `StubProviding` protocol.
public final class StubRegistry: @unchecked Sendable {

    /// Used to make the `StubRegistry` thread-safe.
    private let storageQueue = DispatchQueue(label: "StubRegistryStorageQueue")

    private var propertyStubs: [String: Stub] = [:]
    private var functionStubs: [FunctionStubIdentifier: Stub] = [:]

    /// The type of mock that owns this StubRegistry
    private let mockType: Any.Type

    var isEmpty: Bool { propertyStubs.isEmpty && functionStubs.isEmpty }

    public init(mockType: Any.Type) {
        self.mockType = mockType
        TestDRSLogger.current?.register(
            component: self,
            mockType: mockType
        )
    }

    func setPropertyStub(stub: Stub, for propertyName: String) {
        TestDRSLogger.current?.log(
            component: self,
            mockType: mockType,
            message: "setting \(String(describing: stub)) for \(propertyName)"
        )
        storageQueue.sync {
            propertyStubs[propertyName] = stub
        }
    }

    func setFunctionStub(stub: Stub, for identifier: FunctionStubIdentifier) {
        TestDRSLogger.current?.log(
            component: self,
            mockType: mockType,
            message: "setting stub for \(identifier.signature)"
        )
        storageQueue.sync {
            functionStubs[identifier] = stub
        }
    }

    func getValue<Output>(for propertyName: String) throws -> Output {
        let output: Output = try storageQueue.sync {
            guard let stub = propertyStubs[propertyName] else {
                throw StubError.noStub
            }
            return try stub.evaluate()
        }

        TestDRSLogger.current?.log(
            component: self,
            mockType: mockType,
            message: "returning stub for property \(propertyName)"
        )

        return output
    }

    /// Retrieves the output value for a given input and function signature.
    ///
    /// - Parameters:
    ///   - input: The input value for the function.
    ///   - signature: The signature of the function.
    /// - Returns: The output value for the given input and function signature.
    /// - Throws: `StubError.noStub` if no stub is registered for the given input and function signature, or any error thrown by the registered closure.
    func getOutput<Input, Output>(for input: Input, withSignature signature: FunctionSignature) throws -> Output {
        let stub = storageQueue.sync {
            let identifier = FunctionStubIdentifier(signature: signature, inputType: Input.self, outputType: Output.self)

            // Stubs could be set with either the full signature like `foo(paramOne:)`
            // or if there is no ambiguity, they could be set with an abbreviated signature like `foo`.
            // When we go to retrieve them, we should have the full signature since it is captured by #function.
            // So first we try to retrieve using the full signature provided, and then using the abbreviated version.
            return functionStubs[identifier] ?? functionStubs[identifier.abbreviatedIdentifier]
        }

        guard let stub else {
            if let void = Void() as? Output {
                return void
            }
            throw StubError.noStub
        }

        // Evaluate the stub outside of the storageQueue so that we don't deadlock
        let output: Output = try stub.evaluate(with: input)

        TestDRSLogger.current?.log(
            component: self,
            mockType: mockType,
            message: "returning stub for \(signature)"
        )

        return output
    }

}

// MARK: CustomDebugStringConvertible
extension StubRegistry: CustomDebugStringConvertible {

    public var debugDescription: String {
        storageQueue.sync {
            var sections: [String] = []

            if !propertyStubs.isEmpty {
                let propertyStubDescriptions = propertyStubs
                    .sorted(by: { $0.key < $1.key })
                    .map { stub -> String in
                        """
                        ******* Property Stub *******
                        \(String(reflecting: stub.key))
                        \(String(reflecting: stub.value))
                        """
                    }
                    .joined(separator: .emptyLine)
                sections.append(propertyStubDescriptions)
            }

            if !functionStubs.isEmpty {
                let functionStubDescriptions = functionStubs
                    .sorted(by: { $0.key.signature.name < $1.key.signature.name })
                    .map { stub -> String in
                        """
                        ******* Function Stub *******
                        \(String(reflecting: stub.key))
                        \(String(reflecting: stub.value))
                        """
                    }
                    .joined(separator: .emptyLine)
                sections.append(functionStubDescriptions)
            }

            return sections.isEmpty ? "\n(no stubs configured)" + .emptyLine : "\n" + sections.joined(separator: .emptyLine) + .emptyLine
        }
    }

}

extension String {
    // Used to separate output in the console, the space is needed so that the newline isn't stripped.
    static let emptyLine = "\n \n"
}
