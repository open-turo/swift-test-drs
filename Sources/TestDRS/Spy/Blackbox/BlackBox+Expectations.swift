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
        location: SourceLocation,
        reportFailure: @escaping ReportFailure
    ) -> ExpectWasCalledResult<MatchingAnyAmount, Input, Output> {
        let calls = callsMatching(signature: signature, taking: Input.self, returning: Output.self)

        if calls.isEmpty {
            let message: String
            if callsMatching(signature: signature).isEmpty {
                message = "No calls to \(signature) were recorded"
            } else {
                message = "No calls to \(signature) with input type \(Input.self) and output type \(Output.self) were recorded"
            }
            reportFailure(message, location)
        }

        return ExpectWasCalledResult(matchingCalls: calls, blackBox: self, reportFailure: reportFailure)
    }

    func expectWasCalled<each Input, Output>(
        _ function: (repeat each Input) async throws -> Output,
        signature: FunctionSignature,
        expectedInput: repeat each Input,
        location: SourceLocation,
        reportFailure: @escaping ReportFailure
    ) -> ExpectWasCalledResult<MatchingAnyAmount, (repeat each Input), Output> where repeat each Input: Equatable {
        let calls = callsMatching(signature: signature, taking: (repeat each Input).self, returning: Output.self)
        let callsWithExpectedInput = calls.filter { check(repeat each expectedInput, against: $0.input) }

        if calls.isEmpty {
            let message: String
            if callsMatching(signature: signature).isEmpty {
                message = "No calls to \(signature) were recorded"
            } else {
                message = "No calls to \(signature) with input type \((repeat each Input).self) and output type \(Output.self) were recorded"
            }
            reportFailure(message, location)
        } else if callsWithExpectedInput.isEmpty {
            let actualInputs = calls
                .map { "+\($0.input)" }
                .joined(separator: "\n")
            let message = "\(signature) was not called with expected input (-), but was called with other input (+):\n\n-\((repeat each expectedInput))\n\(actualInputs)"
            reportFailure(message, location)
        }

        return ExpectWasCalledResult(matchingCalls: callsWithExpectedInput, blackBox: self, reportFailure: reportFailure)
    }

    // MARK: - expectWasNotCalled

    func expectWasNotCalled<Input, Output>(
        _ function: (Input) async throws -> Output,
        signature: FunctionSignature,
        location: SourceLocation,
        reportFailure: ReportFailure
    ) {
        let calls = callsMatching(signature: signature, taking: Input.self, returning: Output.self)

        if !calls.isEmpty {
            let message = "\(calls.count) calls to \(signature) with input type \(Input.self) and output type \(Output.self) were recorded"
            reportFailure(message, location)
        }
    }

}
