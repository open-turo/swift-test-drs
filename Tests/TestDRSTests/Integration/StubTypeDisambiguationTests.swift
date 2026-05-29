//
// Created on 1/16/25.
// Copyright © 2025 Turo Open Source. All rights reserved.
//

import TestDRS
import Testing

struct StubTypeDisambiguationTests {

    private let mock = MockDisambiguationTesting()

    @Test func disambiguateInputType_ReturningOutput() {
        #stub(mock.foo, taking: String.self, returning: "Taking a String")
        #stub(mock.foo, taking: Bool.self, returning: "Taking a Bool")

        #expect(mock.foo(paramOne: "Hello World") == "Taking a String")
        #expect(mock.foo(paramOne: true) == "Taking a Bool")
    }

    @Test func disambiguateInputType_ThrowingError() {
        #stub(mock.bar, taking: String.self, throwing: MockError.stringInput)
        #stub(mock.bar, taking: Bool.self, throwing: MockError.boolInput)

        #expect(throws: MockError.stringInput) {
            try mock.bar(paramOne: "Hello World")
        }
        #expect(throws: MockError.boolInput) {
            try mock.bar(paramOne: true)
        }
    }

    @Test func disambiguateOutputType_ThrowingError() {
        #stub(mock.fetch, returning: String.self, throwing: MockError.stringOutput)
        #stub(mock.fetch, returning: Int.self, throwing: MockError.intOutput)

        #expect(throws: MockError.stringOutput) {
            let _: String = try mock.fetch()
        }
        #expect(throws: MockError.intOutput) {
            let _: Int = try mock.fetch()
        }
    }

}

@AddMock
private protocol DisambiguationTesting {

    func foo(paramOne: String) -> String
    func foo(paramOne: Bool) -> String
    func bar(paramOne: String) throws
    func bar(paramOne: Bool) throws
    func fetch<T>() throws -> T

}

private enum MockError: Error {
    case stringInput
    case boolInput
    case stringOutput
    case intOutput
}
