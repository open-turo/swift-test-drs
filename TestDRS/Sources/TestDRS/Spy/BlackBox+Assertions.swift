//
// Created on 5/13/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

// swiftformat:disable spaceAroundOperators

extension BlackBox {

    // MARK: - assertCallCount

    func assertCallCount<Input, Output>(
        to function: (Input) async throws -> Output,
        signature: String,
        equals expectedCount: Int,
        file: StaticString,
        line: UInt
    ) {
        let calls = callsMatching(signature: signature, taking: Input.self, returning: Output.self)

        if calls.count != expectedCount {
            var message = "Expected \(signature) to be called \(expectedCount) times, but \(calls.count) calls were recorded with input type \(Input.self) and output type \(Output.self)"
            if !calls.isEmpty {
                message += ":\n\n"
                message += calls
                    .map { "+\($0.input)" }
                    .joined(separator: "\n")
            }
            reportFailure(message: message, file: file, line: line)
        }
    }

    // MARK: - assertWasCalled

    @discardableResult
    func assertWasCalled<each Input, Output>(
        _ function: (repeat each Input) async throws -> Output,
        signature: String,
        expectedInput: repeat each Input,
        file: StaticString,
        line: UInt
    ) -> ConcreteFunctionCall<(repeat each Input), Output>? where repeat each Input: Equatable {
        let calls = callsMatching(signature: signature, taking: (repeat each Input).self, returning: Output.self)

        guard !calls.isEmpty else {
            let message: String
            if callsMatching(signature: signature).isEmpty {
                message = "No calls to \(signature) were recorded"
            } else {
                message = "No calls to \(signature) with input type \((repeat each Input).self) and output type \(Output.self) were recorded"
            }
            reportFailure(message: message, file: file, line: line)
            return nil
        }

        guard let call = calls.first(where: { check(repeat each expectedInput, against: $0.input) }) else {
            let actualInputs = calls
                .map { "+\($0.input)" }
                .joined(separator: "\n")
            let message = "\(signature) was not called with expected input (-), but was called with other input (+):\n\n-\((repeat each expectedInput))\n\(actualInputs)"
            reportFailure(message: message, file: file, line: line)
            return nil
        }

        return call
    }

    @discardableResult
    func assertWasCalled<Input, Output>(
        _ function: (Input) async throws -> Output,
        signature: String,
        where predicate: ((ConcreteFunctionCall<Input, Output>) throws -> Bool)?,
        file: StaticString,
        line: UInt
    ) -> ConcreteFunctionCall<Input, Output>? {
        let calls = callsMatching(signature: signature, taking: Input.self, returning: Output.self)

        guard !calls.isEmpty else {
            let message: String
            if callsMatching(signature: signature).isEmpty {
                message = "No calls to \(signature) were recorded"
            } else {
                message = "No calls to \(signature) with input type \(Input.self) and output type \(Output.self) were recorded"
            }
            reportFailure(message: message, file: file, line: line)
            return nil
        }

        if let predicate {
            guard let firstCall = try? calls.first(where: predicate) else {
                reportFailure(message: "No calls to \(signature) were recorded where the predicate returned true", file: file, line: line)
                return nil
            }
            return firstCall
        }

        return calls.first
    }

    // MARK: - assertWasCalledExactlyOnce

    @discardableResult
    func assertWasCalledExactlyOnce<each Input, Output>(
        _ function: (repeat each Input) async throws -> Output,
        signature: String,
        expectedInput: repeat each Input,
        file: StaticString,
        line: UInt
    ) -> ConcreteFunctionCall<(repeat each Input), Output>? where repeat each Input: Equatable {
        guard let onlyCall = onlyCall(withSignature: signature, file: file, line: line) else { return nil }

        guard check(repeat each expectedInput, against: onlyCall.input) else {
            let message = "\(signature) was called exactly once, but with different input (+) than expected (-):\n\n-\((repeat each expectedInput))\n+\(onlyCall.input)"
            reportFailure(message: message, file: file, line: line)
            return nil
        }

        guard let concreteCall = onlyCall as? ConcreteFunctionCall<(repeat each Input), Output> else {
            let message = "\(signature) was called exactly once with the expected input, but not with the output type \(Output.self)"
            reportFailure(message: message, file: file, line: line)
            return nil
        }

        return concreteCall
    }

    @discardableResult
    func assertWasCalledExactlyOnce<Input, Output>(
        _ function: (Input) async throws -> Output,
        signature: String,
        file: StaticString,
        line: UInt
    ) -> ConcreteFunctionCall<Input, Output>? {
        guard let onlyCall = onlyCall(withSignature: signature, file: file, line: line) else { return nil }

        guard let concreteCall = onlyCall as? ConcreteFunctionCall<Input, Output> else {
            let message = "\(signature) was called exactly once, but not with input type \(Input.self) and output type \(Output.self)"
            reportFailure(message: message, file: file, line: line)
            return nil
        }

        return concreteCall
    }

    // MARK: - assertWasCalledFirst

    @discardableResult
    func assertWasCalledFirst<each Input, Output>(
        _ function: (repeat each Input) async throws -> Output,
        signature: String,
        expectedInput: repeat each Input,
        file: StaticString,
        line: UInt
    ) -> ConcreteFunctionCall<(repeat each Input), Output>? where repeat each Input: Equatable {
        guard let firstCall = firstCall(signature: signature, file: file, line: line) else { return nil }

        guard check(repeat each expectedInput, against: firstCall.input) else {
            reportFailure(message: "First call was to \(signature), but with different input (+) than expected (-):\n\n-\((repeat each expectedInput))\n+\(firstCall.input)", file: file, line: line)
            return nil
        }

        guard let concreteCall = firstCall as? ConcreteFunctionCall<(repeat each Input), Output> else {
            let message = "First call was to \(signature) with the expected input, but not with the output type \(Output.self)"
            reportFailure(message: message, file: file, line: line)
            return nil
        }

        return concreteCall
    }

    @discardableResult
    func assertWasCalledFirst<Input, Output>(
        _ function: (Input) async throws -> Output,
        signature: String,
        file: StaticString,
        line: UInt
    ) -> ConcreteFunctionCall<Input, Output>? {
        guard let firstCall = firstCall(signature: signature, file: file, line: line) else { return nil }

        guard let concreteCall = firstCall as? ConcreteFunctionCall<Input, Output> else {
            let message = "First call was to \(signature), but not with input type \(Input.self) and output type \(Output.self)"
            reportFailure(message: message, file: file, line: line)
            return nil
        }

        return concreteCall
    }

    // MARK: - assertWasCalledLast

    @discardableResult
    func assertWasCalledLast<each Input, Output>(
        _ function: (repeat each Input) async throws -> Output,
        signature: String,
        expectedInput: repeat each Input,
        immediatelyAfter previousCall: (any FunctionCall)? = nil,
        file: StaticString,
        line: UInt
    ) -> ConcreteFunctionCall<(repeat each Input), Output>? where repeat each Input: Equatable {
        guard let lastCall = lastCall(signature: signature, file: file, line: line) else { return nil }

        guard check(repeat each expectedInput, against: lastCall.input) else {
            reportFailure(message: "Last call was to \(signature), but with different input (+) than expected (-):\n\n-\((repeat each expectedInput))\n+\(lastCall.input)", file: file, line: line)
            return nil
        }

        if let previousCall {
            guard let nextCall = nextCall(after: previousCall, signature: signature, file: file, line: line) else { return nil }
            guard lastCall.signature == nextCall.signature && lastCall.time == nextCall.time else {
                reportFailure(message: "Last call was not immediately after previous call to \(previousCall.signature)", file: file, line: line)
                return nil
            }
        }

        guard let concreteCall = lastCall as? ConcreteFunctionCall<(repeat each Input), Output> else {
            let message = "Last call was to \(signature) with the expected input, but not with the output type \(Output.self)"
            reportFailure(message: message, file: file, line: line)
            return nil
        }

        return concreteCall
    }

    @discardableResult
    func assertWasCalledLast<Input, Output>(
        _ function: (Input) async throws -> Output,
        signature: String,
        immediatelyAfter previousCall: (any FunctionCall)? = nil,
        file: StaticString,
        line: UInt
    ) -> ConcreteFunctionCall<Input, Output>? {
        guard let lastCall = lastCall(signature: signature, file: file, line: line) else { return nil }

        if let previousCall {
            guard let nextCall = nextCall(after: previousCall, signature: signature, file: file, line: line) else { return nil }
            guard lastCall.signature == nextCall.signature && lastCall.time == nextCall.time else {
                reportFailure(message: "Last call was not immediately after previous call to \(previousCall.signature)", file: file, line: line)
                return nil
            }
        }

        guard let concreteCall = lastCall as? ConcreteFunctionCall<Input, Output> else {
            let message = "Last call was to \(signature), but not with input type \(Input.self) and output type \(Output.self)"
            reportFailure(message: message, file: file, line: line)
            return nil
        }

        return concreteCall
    }

    // MARK: - assertWasCalled...after:

    @discardableResult
    func assertWasCalled<each Input, Output>(
        _ function: (repeat each Input) async throws -> Output,
        signature: String,
        expectedInput: repeat each Input,
        after previousCall: (any FunctionCall),
        file: StaticString,
        line: UInt
    ) -> ConcreteFunctionCall<(repeat each Input), Output>? where repeat each Input: Equatable {
        let calls = callsMatching(signature: signature, after: previousCall, taking: (repeat each Input).self, returning: Output.self)

        guard !calls.isEmpty else {
            let message: String
            if callsMatching(signature: signature, after: previousCall).isEmpty {
                message = "No calls to \(signature) were recorded after previous call to \(previousCall.signature)"
            } else {
                message = "No calls to \(signature) with input type \((repeat each Input).self) and output type \(Output.self) were recorded after previous call to \(previousCall.signature)"
            }
            reportFailure(message: message, file: file, line: line)
            return nil
        }

        guard let call = calls.first(where: { check(repeat each expectedInput, against: $0.input) }) else {
            let actualInputs = calls
                .map { "+\($0.input)" }
                .joined(separator: "\n")
            let message = "\(signature) was not called with expected input (-), but was called with other input (+) after previous call to \(previousCall.signature):\n\n-\((repeat each expectedInput))\n\(actualInputs)"
            reportFailure(message: message, file: file, line: line)
            return nil
        }

        return call
    }

    @discardableResult
    func assertWasCalled<Input, Output>(
        _ function: (Input) async throws -> Output,
        signature: String,
        after previousCall: (any FunctionCall),
        file: StaticString,
        line: UInt
    ) -> ConcreteFunctionCall<Input, Output>? {
        let calls = callsMatching(signature: signature, after: previousCall, taking: Input.self, returning: Output.self)

        guard !calls.isEmpty else {
            let message: String
            if callsMatching(signature: signature, after: previousCall).isEmpty {
                message = "No calls to \(signature) were recorded after previous call to \(previousCall.signature)"
            } else {
                message = "No calls to \(signature) with input type \(Input.self) and output type \(Output.self) were recorded after previous call to \(previousCall.signature)"
            }
            reportFailure(message: message, file: file, line: line)
            return nil
        }

        return calls.first
    }

    // MARK: - assertWasCalled...immediatelyAfter:

    @discardableResult
    func assertWasCalled<each Input, Output>(
        _ function: (repeat each Input) async throws -> Output,
        signature: String,
        expectedInput: repeat each Input,
        immediatelyAfter previousCall: (any FunctionCall),
        file: StaticString,
        line: UInt
    ) -> ConcreteFunctionCall<(repeat each Input), Output>? where repeat each Input: Equatable {
        guard let nextCall = nextCall(after: previousCall, signature: signature, file: file, line: line) else { return nil }

        guard check(repeat each expectedInput, against: nextCall.input) else {
            let message = "\(signature) was called with different input (+) than expected (-) immediately after previous call to \(previousCall.signature):\n-\((repeat each expectedInput))\n+\(nextCall.input)"
            reportFailure(message: message, file: file, line: line)
            return nil
        }

        guard let concreteCall = nextCall as? ConcreteFunctionCall<(repeat each Input), Output> else {
            let message = "\(signature) was called immediately after previous call to \(previousCall.signature) but not with input type \((repeat each Input).self) and output type \(Output.self)"
            reportFailure(message: message, file: file, line: line)
            return nil
        }

        return concreteCall
    }

    @discardableResult
    func assertWasCalled<Input, Output>(
        _ function: (Input) async throws -> Output,
        signature: String,
        immediatelyAfter previousCall: (any FunctionCall),
        file: StaticString,
        line: UInt
    ) -> ConcreteFunctionCall<Input, Output>? {
        guard let nextCall = nextCall(after: previousCall, signature: signature, file: file, line: line) else { return nil }

        guard let concreteCall = nextCall as? ConcreteFunctionCall<Input, Output> else {
            let message = "\(signature) was called immediately after previous call to \(previousCall.signature) but not with input type \(Input.self) and output type \(Output.self)"
            reportFailure(message: message, file: file, line: line)
            return nil
        }

        return concreteCall
    }

}
