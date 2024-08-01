//
// Created on 8/1/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

extension Spy {

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
    ) async -> FunctionCallConfirmation < MatchingFirst, (repeat each Input), Output> {
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
