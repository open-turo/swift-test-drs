//
// Created on 8/1/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

public extension Spy {

    /// Awaits confirmation of a function call.
    ///
    /// Similar to using a `Confirmation` in Swift Testing, this macro allows you to await confirmation that a function was called in
    /// scenarios where you can't await the function directly.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to expect was called.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - outputType: An optional phantom parameter used to derive the output type of the `function` passed in.
    ///   - timeLimit: The maximum amount of time to wait for confirmation. If the time limit is reached before the first call can be confirmed, a test failure is reported. Defaults to a duration that is effectively infinite.
    /// - Returns: A `FunctionCallConfirmation` that waits for the first matching call. Further calls can be confirmed by calling methods on this confirmation.
    @available(iOS 16.0, *)
    @discardableResult
    func confirmationOfCall<Input, Output>(
        to function: (Input) async throws -> Output,
        withSignature signature: FunctionSignature,
        taking inputType: Input.Type? = nil,
        returning outputType: Output.Type? = nil,
        timeLimit: Duration = .maxTimeLimit,
        isolation: isolated(any Actor)? = #isolation,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) async -> FunctionCallConfirmation<MatchingFirst, Input, Output> {
        let location = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
        let stream = blackBox.streamForCallsMatching(
            signature: signature,
            taking: Input.self,
            returning: Output.self
        )
        return await FunctionCallConfirmation.confirmFirstCall(
            stream: stream,
            signature: signature,
            blackBox: blackBox,
            timeLimit: timeLimit,
            location: location
        )
    }

    /// Awaits confirmation of a function call with an expected input.
    ///
    /// Similar to using a `Confirmation` in Swift Testing, this macro allows you to await confirmation that a function was called in
    /// scenarios where you can't await the function directly.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to expect was called.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - outputType: An optional phantom parameter used to derive the output type of the `function` passed in.
    ///   - timeLimit: The maximum amount of time to wait for confirmation. If the time limit is reached before the first call can be confirmed, a test failure is reported. Defaults to a duration that is effectively infinite.
    /// - Returns: A `FunctionCallConfirmation` that waits for the first matching call. Further calls can be confirmed by calling methods on this confirmation.
    @available(iOS 16.0, *)
    @discardableResult
    func confirmationOfCall<each Input: Equatable, Output>(
        to function: (repeat each Input) async throws -> Output,
        withSignature signature: FunctionSignature,
        expectedInput: repeat each Input,
        returning: Output.Type? = nil,
        timeLimit: Duration = .maxTimeLimit,
        isolation: isolated(any Actor)? = #isolation,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) async -> FunctionCallConfirmation <MatchingFirst, (repeat each Input), Output> {
        let location = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
        let stream = blackBox.streamForCallsMatching(
            signature: signature,
            withExpectedInput: repeat each expectedInput,
            returning: Output.self
        )
        return await FunctionCallConfirmation.confirmFirstCall(
            stream: stream,
            signature: signature,
            blackBox: blackBox,
            timeLimit: timeLimit,
            location: location
        )
    }

}
