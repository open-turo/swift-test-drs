//
// Created on 5/13/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

// swiftformat:disable spaceAroundOperators

extension BlackBox {

    // MARK: - expectWasCalled

    func expectWasCalled<Input, Output>(
        _ function: (Input) async throws -> Output,
        signature: FunctionSignature,
        mode: ExpectedCallMode,
        location: SourceLocation
    ) -> ExpectWasCalledResult<MatchingAnyAmount, Input, Output> {
        let callsWithMatchingSignature = callsMatching(signature: signature)
        let matchingCalls = callsWithMatchingSignature.compactMap(taking: Input.self, returning: Output.self)

        if matchingCalls.isEmpty {
            let message: String
            if callsMatching(signature: signature).isEmpty {
                message = "No calls to \(signature) were recorded"
            } else {
                message = "No calls to \(signature) with input type \(Input.self) and output type \(Output.self) were recorded"
            }
            reportFailure(message, location: location)
        } else if mode == .exclusive {
            if matchingCalls.count != callsWithMatchingSignature.count {
                let expectedCallIds = matchingCalls.map { $0.id }
                let unexpectedCalls = callsWithMatchingSignature
                    .filter { !expectedCallIds.contains($0.id) }
                    .map { $0.debugDescription }
                    .joined(separator: "\n")
                let messaage = "\(signature) was called with input type \(Input.self) and output type \(Output.self), but was also called with other input and/or output types:\n\n\(unexpectedCalls)"
                reportFailure(messaage, location: location)
            }
        }

        return ExpectWasCalledResult(matchingCalls: matchingCalls, blackBox: self)
    }

    func expectWasCalled<each Input: Equatable, Output>(
        _ function: (repeat each Input) async throws -> Output,
        signature: FunctionSignature,
        expectedInput: repeat each Input,
        mode: ExpectedCallMode,
        location: SourceLocation
    ) -> ExpectWasCalledResult<MatchingAnyAmount, (repeat each Input), Output> {
        let callsWithMatchingSignature = callsMatching(signature: signature)
        let callsWithExpectedType = callsWithMatchingSignature.compactMap(taking: (repeat each Input).self, returning: Output.self)
        let matchingCalls = callsWithExpectedType.filter { check(repeat each expectedInput, against: $0.input) }

        if callsWithMatchingSignature.isEmpty {
            let message: String
            if callsMatching(signature: signature).isEmpty {
                message = "No calls to \(signature) were recorded"
            } else {
                message = "No calls to \(signature) with input type \((repeat each Input).self) and output type \(Output.self) were recorded"
            }
            reportFailure(message, location: location)
        } else if matchingCalls.isEmpty {
            let actualInputs = callsWithMatchingSignature
                .map { "+\($0.input)" }
                .joined(separator: "\n")
            let message = "\(signature) was not called with expected input (-), but was called with other input (+):\n\n-\((repeat each expectedInput))\n\(actualInputs)"
            reportFailure(message, location: location)
        } else if mode == .exclusive {
            if matchingCalls.count != callsWithMatchingSignature.count {
                let expectedCallIDs = matchingCalls.map { $0.id }
                let unexpectedInputs = callsWithMatchingSignature
                    .filter { !expectedCallIDs.contains($0.id) }
                    .map { "+\($0.input)" }
                    .joined(separator: "\n")
                let message = "\(signature) was called with the expected input, but was also called with other input:\n\n\(unexpectedInputs)"
                reportFailure(message, location: location)
            }
        }

        return ExpectWasCalledResult(matchingCalls: matchingCalls, blackBox: self)
    }

    // MARK: - expectWasNotCalled

    func expectWasNotCalled<Input, Output>(
        _ function: (Input) async throws -> Output,
        signature: FunctionSignature,
        location: SourceLocation
    ) {
        let calls = callsMatching(signature: signature)
            .compactMap(taking: Input.self, returning: Output.self)

        if !calls.isEmpty {
            let message = "\(calls.count) calls to \(signature) with input type \(Input.self) and output type \(Output.self) were recorded"
            reportFailure(message, location: location)
        }
    }

}
