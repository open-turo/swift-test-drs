//
// Created on 4/30/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// A protocol to enable spying on function calls.
public protocol Spy: StaticTestable {
    var blackBox: BlackBox { get }
}

public extension Spy {

    /// Records a function call along with details about how it and when it was called.
    /// - Parameters:
    ///   - input: The parameter(s) passed in to the function. For multiple parameters, use a tuple. Defaults to `Void()`.
    ///   - time: The time when the function was called.
    ///   - outputType: The output type that will be returned from the function.
    ///   - signature: **Do not pass in this argument**, it will automatically capture the signature of the calling function.
    func recordCall<Input, Output>(
        with input: Input = Void(),
        at time: Date = Date(),
        returning outputType: Output.Type = Void.self,
        signature: String = #function
    ) {
        blackBox.recordCall(
            with: input,
            at: time,
            returning: outputType,
            signature: signature
        )
    }

    /// Records a static function call along with details about how it and when it was called.
    /// - Parameters:
    ///   - input: The parameter(s) passed in to the function. For multiple parameters, use a tuple. Defaults to `Void()`.
    ///   - time: The time when the function was called.
    ///   - outputType: The output type that will be returned from the function.
    ///   - signature: **Do not pass in this argument**, it will automatically capture the signature of the calling function.
    /// - Returns: The un-modified `output` that was passed in to `recordCall`.
    static func recordCall<Input, Output>(
        with input: Input = Void(),
        at time: Date = Date(),
        returning outputType: Output.Type = Void.self,
        signature: String = #function
    ) {
        getStaticBlackBox().recordCall(
            with: input,
            at: time,
            returning: outputType,
            signature: signature
        )
    }

}
