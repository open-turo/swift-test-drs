//
// Created on 8/21/25.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

@testable import TestDRS
import TestDRSTestSupport
import Testing

struct LoggingTests {

    @Test
    func testLogging() async {
        let mockPrinter = MockPrinter()

        withTestDRSLogging(print: mockPrinter.print) {
            let mock1 = SomePublicMockClass()
            let mock2 = SomePublicMockClass()

            #stub(mock1.baz, returning: "first")
            #stub(mock2.baz, returning: "second")

            _ = mock1.baz(paramOne: true, paramTwo: "hello")
            _ = mock2.baz(paramOne: true, paramTwo: "hello")
        }

        let logs = await #confirmationOfCall(to: mockPrinter.print)
            .occurring(times: 10)
            .matchingCalls.map { $0.input }

        #expect(logs == [
            #"🏎️ Registered SomePublicMockClass.BlackBox"#,
            #"🏎️ Registered SomePublicMockClass.StubRegistry"#,
            #"🏎️ Registered SomePublicMockClass2️⃣.BlackBox"#,
            #"🏎️ Registered SomePublicMockClass2️⃣.StubRegistry"#,
            #"🏎️ SomePublicMockClass.StubRegistry setting stub for "baz""#,
            #"🏎️ SomePublicMockClass2️⃣.StubRegistry setting stub for "baz""#,
            #"🏎️ SomePublicMockClass.BlackBox called "baz(paramOne:paramTwo:)""#,
            #"🏎️ SomePublicMockClass.StubRegistry returning stub for "baz(paramOne:paramTwo:)""#,
            #"🏎️ SomePublicMockClass2️⃣.BlackBox called "baz(paramOne:paramTwo:)""#,
            #"🏎️ SomePublicMockClass2️⃣.StubRegistry returning stub for "baz(paramOne:paramTwo:)""#,
        ])
    }

    @Test
    func testLoggingWithCustomIdentifierAndTestName() async {
        let mockPrinter = MockPrinter()

        withTestDRSLogging(testName: #function, identifier: "🙈", print: mockPrinter.print) {
            let mock1 = SomePublicMockClass()
            let mock2 = SomePublicMockClass()

            #stub(mock1.baz, returning: "first")
            #stub(mock2.baz, returning: "second")

            _ = mock1.baz(paramOne: true, paramTwo: "hello")
            _ = mock2.baz(paramOne: true, paramTwo: "hello")
        }

        let logs = await #confirmationOfCall(to: mockPrinter.print)
            .occurring(times: 10)
            .matchingCalls.map { $0.input }

        #expect(logs == [
            #"🙈 Registered SomePublicMockClass.BlackBox in testLoggingWithCustomIdentifierAndTestName()"#,
            #"🙈 Registered SomePublicMockClass.StubRegistry in testLoggingWithCustomIdentifierAndTestName()"#,
            #"🙈 Registered SomePublicMockClass2️⃣.BlackBox in testLoggingWithCustomIdentifierAndTestName()"#,
            #"🙈 Registered SomePublicMockClass2️⃣.StubRegistry in testLoggingWithCustomIdentifierAndTestName()"#,
            #"🙈 SomePublicMockClass.StubRegistry setting stub for "baz" in testLoggingWithCustomIdentifierAndTestName()"#,
            #"🙈 SomePublicMockClass2️⃣.StubRegistry setting stub for "baz" in testLoggingWithCustomIdentifierAndTestName()"#,
            #"🙈 SomePublicMockClass.BlackBox called "baz(paramOne:paramTwo:)" in testLoggingWithCustomIdentifierAndTestName()"#,
            #"🙈 SomePublicMockClass.StubRegistry returning stub for "baz(paramOne:paramTwo:)" in testLoggingWithCustomIdentifierAndTestName()"#,
            #"🙈 SomePublicMockClass2️⃣.BlackBox called "baz(paramOne:paramTwo:)" in testLoggingWithCustomIdentifierAndTestName()"#,
            #"🙈 SomePublicMockClass2️⃣.StubRegistry returning stub for "baz(paramOne:paramTwo:)" in testLoggingWithCustomIdentifierAndTestName()"#,
        ])
    }

}

@Mock
private struct MockPrinter {
    func print(_ string: String)
}
