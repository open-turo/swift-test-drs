//
// Created on 4/30/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// Extension for `BlackBox` that provides assertion utilities.
extension BlackBox {

    /// Retrieves the only recorded function call that matches the given signature, if indeed there is only one call recorded.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function call to search for.
    ///   - file: The file where the assertion is being made.
    ///   - line: The line number where the assertion is being made.
    /// - Returns: The only recorded function call that matches the given signature, or `nil` if zero or multiple calls were recorded with the given signature.
    func onlyCall(withSignature signature: String, file: StaticString, line: UInt) -> (any FunctionCall)? {
        let calls = callsMatching(signature: signature)
        guard calls.count == 1, let onlyCall = calls.first else {
            let message = "Expected \(signature) to be called exactly once, but \(calls.count) calls were recorded"
            reportFailure(message: message, file: file, line: line)
            return nil
        }
        return onlyCall
    }

    /// Retrieves the first recorded function call that matches the given signature.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function call to search for.
    ///   - file: The file where the assertion is being made.
    ///   - line: The line number where the assertion is being made.
    /// - Returns: The first recorded function call that matches the given signature, or `nil` if no calls were recorded or if the first call does not match the signature.
    func firstCall(signature: String, file: StaticString, line: UInt) -> (any FunctionCall)? {
        guard let firstCall = firstCall else {
            reportFailure(message: "No calls were recorded", file: file, line: line)
            return nil
        }
        guard firstCall.signature == signature else {
            reportFailure(message: "\(firstCall.signature) was called first", file: file, line: line)
            return nil
        }

        return firstCall
    }

    /// Retrieves the last recorded function call that matches the given signature.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function call to search for.
    ///   - file: The file where the assertion is being made.
    ///   - line: The line number where the assertion is being made.
    /// - Returns: The last recorded function call that matches the given signature, or `nil` if no calls were recorded or if the last call does not match the signature.
    func lastCall(signature: String, file: StaticString, line: UInt) -> (any FunctionCall)? {
        guard let lastCall = lastCall else {
            reportFailure(message: "No calls were recorded", file: file, line: line)
            return nil
        }
        guard lastCall.signature == signature else {
            reportFailure(message: "\(lastCall.signature) was called last", file: file, line: line)
            return nil
        }

        return lastCall
    }

    /// Retrieves the next recorded function call after the given previous call that matches the given signature.
    ///
    /// - Parameters:
    ///   - previousCall: The previous function call.
    ///   - signature: The signature of the function call to search for.
    ///   - file: The file where the assertion is being made.
    ///   - line: The line number where the assertion is being made.
    /// - Returns: The next recorded function call after the given previous call that matches the given signature, or `nil` if no calls were recorded after the previous call or if the next call does not match the signature.
    func nextCall(after previousCall: (any FunctionCall), signature: String, file: StaticString, line: UInt) -> (any FunctionCall)? {
        guard let nextCall = callAfter(previousCall) else {
            reportFailure(message: "No calls were recorded after \(previousCall.signature)", file: file, line: line)
            return nil
        }
        guard nextCall.signature == signature else {
            reportFailure(message: "\(nextCall.signature) was called immediately after \(previousCall.signature)", file: file, line: line)
            return nil
        }
        return nextCall
    }

    /// Checks if the expected input matches the actual input.
    ///
    /// - Parameters:
    ///   - expectedInput: The expected input.
    ///   - actualInput: The actual input.
    /// - Returns: `true` if the expected input matches the actual input, `false` otherwise.
    func check<each Input>(_ expectedInput: repeat each Input, against actualInput: Any) -> Bool where repeat each Input: Equatable {
        let expectedInput = (repeat each expectedInput)

        guard (repeat each Input).self != Void.self else { return true }
        guard let actualInput = actualInput as? (repeat each Input) else { return false }

        return checkEqual(
            lhs: repeat each actualInput.element,
            rhs: repeat each expectedInput.element
        )
    }

    private func checkEqual<each T: Equatable>(lhs: repeat each T, rhs: repeat each T) -> Bool {
        do {
            // The only way to implement control flow within a repeat is to try a throwing method.
            // TODO: Update to use pack iteration with Swift 6: https://www.swift.org/blog/pack-iteration/
            repeat try checkEqualOrThrow(each lhs, each rhs)
        } catch {
            return false
        }

        return true
    }

    private func checkEqualOrThrow<T: Equatable>(_ lhs: T, _ rhs: T) throws {
        if lhs != rhs { throw NotEqualError() }
    }
}

private struct NotEqualError: Error { }
