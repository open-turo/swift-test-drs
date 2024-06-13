//
// Created on 4/30/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import TestDRSCore

/// Extension for `BlackBox` that provides assertion utilities.
extension BlackBox {

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
