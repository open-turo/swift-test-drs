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

        withMockLogging(print: mockPrinter.print) {
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
            #"🏎️ Registered SomePublicMockClass.BlackBox in testLogging()"#,
            #"🏎️ Registered SomePublicMockClass.StubRegistry in testLogging()"#,
            #"🏎️ Registered SomePublicMockClass2️⃣.BlackBox in testLogging()"#,
            #"🏎️ Registered SomePublicMockClass2️⃣.StubRegistry in testLogging()"#,
            #"🏎️ SomePublicMockClass.StubRegistry setting stub for "baz" in testLogging()"#,
            #"🏎️ SomePublicMockClass2️⃣.StubRegistry setting stub for "baz" in testLogging()"#,
            #"🏎️ SomePublicMockClass.BlackBox called "baz(paramOne:paramTwo:)" in testLogging()"#,
            #"🏎️ SomePublicMockClass.StubRegistry returning stub for "baz(paramOne:paramTwo:)" in testLogging()"#,
            #"🏎️ SomePublicMockClass2️⃣.BlackBox called "baz(paramOne:paramTwo:)" in testLogging()"#,
            #"🏎️ SomePublicMockClass2️⃣.StubRegistry returning stub for "baz(paramOne:paramTwo:)" in testLogging()"#,
        ])
    }

    @Test
    func testLoggingWithCustomIdentifier() async {
        let mockPrinter = MockPrinter()

        withMockLogging(identifier: "🙈", print: mockPrinter.print) {
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
            #"🙈 Registered SomePublicMockClass.BlackBox in testLoggingWithCustomIdentifier()"#,
            #"🙈 Registered SomePublicMockClass.StubRegistry in testLoggingWithCustomIdentifier()"#,
            #"🙈 Registered SomePublicMockClass2️⃣.BlackBox in testLoggingWithCustomIdentifier()"#,
            #"🙈 Registered SomePublicMockClass2️⃣.StubRegistry in testLoggingWithCustomIdentifier()"#,
            #"🙈 SomePublicMockClass.StubRegistry setting stub for "baz" in testLoggingWithCustomIdentifier()"#,
            #"🙈 SomePublicMockClass2️⃣.StubRegistry setting stub for "baz" in testLoggingWithCustomIdentifier()"#,
            #"🙈 SomePublicMockClass.BlackBox called "baz(paramOne:paramTwo:)" in testLoggingWithCustomIdentifier()"#,
            #"🙈 SomePublicMockClass.StubRegistry returning stub for "baz(paramOne:paramTwo:)" in testLoggingWithCustomIdentifier()"#,
            #"🙈 SomePublicMockClass2️⃣.BlackBox called "baz(paramOne:paramTwo:)" in testLoggingWithCustomIdentifier()"#,
            #"🙈 SomePublicMockClass2️⃣.StubRegistry returning stub for "baz(paramOne:paramTwo:)" in testLoggingWithCustomIdentifier()"#,
        ])
    }

}

@Mock
private struct MockPrinter {
    func print(_ string: String)
}
