//
// Created on 5/13/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

extension BlackBox {

    func assertCallCount(
        to signature: String,
        equals expectedCount: Int,
        file: StaticString,
        line: UInt
    ) {
        let calls = callsMatching(signature: signature)
        if calls.count != expectedCount {
            var message = "Expected \(signature) to be called \(expectedCount) times, but \(calls.count) calls were recorded\n"
            message += calls
                .map { "+\($0.input)" }
                .joined(separator: "\n")
            reportFailure(message: message, file: file, line: line)
        }
    }

    func assertCallCount<Input>(
        to signature: String,
        withInputType inputType: Input.Type,
        equals expectedCount: Int,
        file: StaticString,
        line: UInt
    ) {
        let calls = callsMatching(signature: signature, taking: inputType)
        if calls.count != expectedCount {
            var message = "Expected \(signature) to be called \(expectedCount) times, but \(calls.count) calls were recorded\n"
            message += calls
                .map { "+\(String(describing: $0.input))" }
                .joined(separator: "\n")
            reportFailure(message: message, file: file, line: line)
        }
    }

    @discardableResult
    func assertWasCalled<each T>(
        _ signature: String,
        with expectedInput: repeat each T,
        file: StaticString,
        line: UInt
    ) -> (any FunctionCall)? where repeat each T: Equatable {
        let calls = callsMatching(signature: signature, taking: (repeat each T).self)
        guard !calls.isEmpty else {
            if callsMatching(signature: signature).isEmpty {
                reportFailure(message: "No calls to \(signature) were recorded", file: file, line: line)
            } else {
                reportFailure(message: "No calls to \(signature) with input type \((repeat each T).self) were recorded", file: file, line: line)
            }
            return nil
        }
        guard let call = calls.first(where: { check(repeat each expectedInput, against: $0.input) }) else {
            var message = "\(signature) was not called with expected input (-), but was called with other input (+):\n-\((repeat each expectedInput))\n"
            message += calls
                .map { "+\($0.input)" }
                .joined(separator: "\n")
            reportFailure(message: message, file: file, line: line)
            return nil
        }
        return call
    }

    @discardableResult
    func assertWasCalledExactlyOnce<each Input>(
        _ signature: String,
        with expectedInput: repeat each Input,
        file: StaticString,
        line: UInt
    ) -> (any FunctionCall)? where repeat each Input: Equatable {
        let calls = callsMatching(signature: signature)
        guard calls.count == 1, let onlyCall = calls.first else {
            let message = "Expected \(signature) to be called exactly once, but \(calls.count) calls were recorded\n"
            reportFailure(message: message, file: file, line: line)
            return nil
        }
        guard check(repeat each expectedInput, against: onlyCall.input) else {
            reportFailure(message: "\(signature) was called exactly once, but with different input (+) than expected (-):\n-\((repeat each expectedInput))\n+\(onlyCall.input)", file: file, line: line)
            return nil
        }
        return onlyCall
    }

    @discardableResult
    func assertWasCalledFirst<each T>(
        _ signature: String,
        with expectedInput: repeat each T,
        file: StaticString,
        line: UInt
    ) -> (any FunctionCall)? where repeat each T: Equatable {
        guard let firstCall = firstCall(signature: signature, file: file, line: line) else { return nil }
        guard check(repeat each expectedInput, against: firstCall.input) else {
            reportFailure(message: "First call was to \(signature), but with different input (+) than expected (-):\n-\((repeat each expectedInput))\n+\(firstCall.input)", file: file, line: line)
            return nil
        }
        return firstCall
    }

    @discardableResult
    func assertWasCalledLast<each T>(
        _ signature: String,
        with expectedInput: repeat each T,
        immediatelyAfter previousCall: (any FunctionCall)? = nil,
        file: StaticString,
        line: UInt
    ) -> (any FunctionCall)? where repeat each T: Equatable {
        guard let lastCall = lastCall(signature: signature, file: file, line: line) else { return nil }
        guard check(repeat each expectedInput, against: lastCall.input) else {
            reportFailure(message: "Last call was to \(signature), but with different input (+) than expected (-):\n-\((repeat each expectedInput))\n+\(lastCall.input)", file: file, line: line)
            return nil
        }
        if let previousCall {
            guard let nextCall = nextCall(after: previousCall, signature: signature, file: file, line: line) else { return nil }
            guard lastCall.signature == nextCall.signature && lastCall.time == nextCall.time else {
                reportFailure(message: "Last call was not immediately after previous call to \(previousCall.signature)", file: file, line: line)
                return nil
            }
        }
        return lastCall
    }

    @discardableResult
    func assertWasCalled<each T>(
        _ signature: String,
        with expectedInput: repeat each T,
        after previousCall: (any FunctionCall),
        file: StaticString,
        line: UInt
    ) -> (any FunctionCall)? where repeat each T: Equatable {
        let calls = callsMatching(signature: signature, after: previousCall, taking: (repeat each T).self)
        guard !calls.isEmpty else {
            if callsMatching(signature: signature).isEmpty {
                reportFailure(message: "No calls to \(signature) were recorded", file: file, line: line)
            } else {
                reportFailure(message: "No calls to \(signature) with input type \((repeat each T).self) were recorded", file: file, line: line)
            }
            return nil
        }
        guard let call = calls.first(where: { check(repeat each expectedInput, against: $0.input) }) else {
            var message = "\(signature) was not called with expected input (-), but was called with other input (+) after previous call to \(previousCall.signature):\n-\((repeat each expectedInput))\n"
            message += calls
                .map { "+\($0.input)" }
                .joined(separator: "\n")
            reportFailure(message: message, file: file, line: line)
            return nil
        }
        return call
    }

    @discardableResult
    func assertWasCalled<each T>(
        _ signature: String,
        with expectedInput: repeat each T,
        immediatelyAfter previousCall: (any FunctionCall),
        file: StaticString,
        line: UInt
    ) -> (any FunctionCall)? where repeat each T: Equatable {
        guard let nextCall = nextCall(after: previousCall, signature: signature, file: file, line: line) else { return nil }
        guard check(repeat each expectedInput, against: nextCall.input) else {
            reportFailure(message: "\(signature) was called with different input (+) than expected (-) after previous call to \(previousCall.signature):\n-\((repeat each expectedInput))\n+\(nextCall.input)", file: file, line: line)
            return nil
        }
        return nextCall
    }

}
