import TestDRS
import Testing

@AddMock
private protocol ErrorTestService {
    func processData<T>(input: T) -> Int
    var isEnabled: Bool { get }
    var configuration: [String: Any] { get }
}

/// Tests for error messaging when stubs are missing or misconfigured.
/// These tests are disabled by default since they cause fatal errors.
/// To validate error messages manually, temporarily enable individual tests.
@Suite(.disabled("Disabled by default to avoid fatal errors during normal test runs"))
struct StubErrorMessagingTests {

    @Test
    func methodCalledWithNoStubs() {
        let mock = MockErrorTestService()
        _ = mock.processData(input: 7)
    }

    @Test
    func methodCalledWithNoMatchingStub() {
        let mock = MockErrorTestService()
        #stub(mock.processData, taking: String.self, returning: 42)
        _ = mock.processData(input: 7)
    }

    @Test
    func propertyAccessWithNoStubs() {
        let mock = MockErrorTestService()
        _ = mock.isEnabled
    }

    @Test
    func propertyAccessWithNoMatchingStub() {
        let mock = MockErrorTestService()
        mock.isEnabled = true
        _ = mock.configuration
    }

}
