//
// Created on 6/6/25.
// Copyright © 2025 Turo Open Source. All rights reserved.
//

import Foundation
@testable import TestDRS
import Testing

struct ExpectCaseMacroTests {

    enum TestEnum {
        case success
        case failure(String)
        case pending
    }

    enum Result<T, E> {
        case success(T)
        case failure(E)
    }

    // MARK: - Success Cases

    @Test
    func testExpectCase_WithMatchingSimpleCase() {
        let value: TestEnum = .success

        #expectCase(.success, in: value)
    }

    @Test
    func testExpectCase_WithMatchingCaseWithAssociatedValue() {
        let value: TestEnum = .failure("error message")

        #expectCase(.failure("error message"), in: value)
    }

    @Test
    func testExpectCase_WithMatchingGenericResult() {
        let result: Result<String, Error> = .success("test")

        #expectCase(.success("test"), in: result)
    }

    @Test
    func testExpectCase_WithComplexEnum() {
        enum NetworkState {
            case idle
            case loading(progress: Double)
            case loaded(data: Data)
            case error(Error)
        }

        let state: NetworkState = .loading(progress: 0.5)

        #expectCase(.loading(progress: 0.5), in: state)
    }

    @Test
    func testExpectCase_WithOptionalEnum() {
        let optional: TestEnum? = .success

        #expectCase(.some(.success), in: optional)
    }

    @Test
    func testExpectCase_MatchingAnyAssociatedValue() {
        let value: TestEnum = .failure("any error message")

        #expectCase(TestEnum.failure, in: value)
    }

    @Test
    func testExpectCase_WithNilOptional() {
        let optional: TestEnum? = nil

        #expectCase(.none, in: optional)
    }

    // MARK: - Failure Cases

    @Test
    func testExpectCase_WithNonMatchingSimpleCase() {
        let value: TestEnum = .pending

        withKnownIssue {
            #expectCase(.success, in: value)
        } matching: { issue in
            issue.sourceLocation?.line == #line - 2 &&
                issue.sourceLocation?.fileID == #fileID &&
                issue.description.contains("Expected .success, but got pending")
        }
    }

    @Test
    func testExpectCase_WithNonMatchingCaseWithAssociatedValue() {
        let value: TestEnum = .success

        withKnownIssue {
            #expectCase(.failure("some error"), in: value)
        } matching: { issue in
            issue.sourceLocation?.line == #line - 2 &&
                issue.sourceLocation?.fileID == #fileID &&
                issue.description.contains(#"Expected .failure("some error"), but got success"#)
        }
    }

    @Test
    func testExpectCase_WithMatchingCaseButDifferentAssociatedValue() {
        let value: TestEnum = .failure("different error")

        withKnownIssue {
            #expectCase(.failure("expected error"), in: value)
        } matching: { issue in
            issue.sourceLocation?.line == #line - 2 &&
                issue.sourceLocation?.fileID == #fileID &&
                issue.description.contains(#"Expected .failure("expected error"), but got failure("different error")"#)
        }
    }

}
