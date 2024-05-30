//
// Created on 5/13/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

// swiftformat:disable spaceAroundOperators

extension BlackBox {

    // MARK: - assertWasCalled

    func assertWasCalled<Input, Output>(
        _ function: (Input) async throws -> Output,
        signature: String,
        file: StaticString,
        line: UInt
    ) -> AssertWasCalledResult<MatchingAnyAmount, Input, Output> {
        let calls = callsMatching(signature: signature, taking: Input.self, returning: Output.self)

        if calls.isEmpty {
            let message: String
            if callsMatching(signature: signature).isEmpty {
                message = "No calls to \(signature) were recorded"
            } else {
                message = "No calls to \(signature) with input type \(Input.self) and output type \(Output.self) were recorded"
            }
            reportFailure(message: message, file: file, line: line)
        }

        return AssertWasCalledResult(matchingCalls: calls, blackBox: self)
    }

    func assertWasCalled<each Input, Output>(
        _ function: (repeat each Input) async throws -> Output,
        signature: String,
        expectedInput: repeat each Input,
        file: StaticString,
        line: UInt
    ) -> AssertWasCalledResult<MatchingAnyAmount, (repeat each Input), Output> where repeat each Input: Equatable {
        let calls = callsMatching(signature: signature, taking: (repeat each Input).self, returning: Output.self)
        let callsWithExpectedInput = calls.filter { check(repeat each expectedInput, against: $0.input) }

        if calls.isEmpty {
            let message: String
            if callsMatching(signature: signature).isEmpty {
                message = "No calls to \(signature) were recorded"
            } else {
                message = "No calls to \(signature) with input type \((repeat each Input).self) and output type \(Output.self) were recorded"
            }
            reportFailure(message: message, file: file, line: line)
        } else if callsWithExpectedInput.isEmpty {
            let actualInputs = calls
                .map { "+\($0.input)" }
                .joined(separator: "\n")
            let message = "\(signature) was not called with expected input (-), but was called with other input (+):\n\n-\((repeat each expectedInput))\n\(actualInputs)"
            reportFailure(message: message, file: file, line: line)
        }

        return AssertWasCalledResult(matchingCalls: callsWithExpectedInput, blackBox: self)
    }

    // MARK: - assertWasNotCalled

    func assertWasNotCalled<Input, Output>(
        _ function: (Input) async throws -> Output,
        signature: String,
        file: StaticString,
        line: UInt
    ) {
        let calls = callsMatching(signature: signature, taking: Input.self, returning: Output.self)

        if !calls.isEmpty {
            let message = "\(calls.count) calls to \(signature) with input type \(Input.self) and output type \(Output.self) were recorded"
            reportFailure(message: message, file: file, line: line)
        }
    }

}
