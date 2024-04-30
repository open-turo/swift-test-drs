//
// Created on 4/30/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// A protocol to enable spying on function calls.
public protocol Spy: AnyObject {
    var blackBox: BlackBox { get }
}

public extension Spy {

    /// Records a function call along with details about how it and when it was called.
    /// - Parameters:
    ///   - input: The parameter(s) passed in to the method. For multiple parameters, use a tuple. Defaults to `Void()`.
    ///   - time: The time when the function was called.
    ///   - output: The output that will be returned from the function.
    ///   - signature: **Do not pass in this argument**, it will automatically capture the signature of the calling function.
    /// - Returns: The un-modified `output` that was passed in to `recordCall`.
    @discardableResult
    func recordCall<Input, Output>(
        with input: Input = Void(),
        at time: Date,
        returning output: Output = Void(),
        signature: String = #function
    ) -> Output {
        blackBox.recordCall(
            with: input,
            at: time,
            returning: output,
            signature: signature
        )
        return output
    }

    /// Returns all function calls recorded within the `blackBox` that match the given signature.
    func calls(to signature: String) -> [any FunctionCall] {
        blackBox.callsMatching(signature: signature)
    }

}
