import TestDRS
import Testing

@AddMock
private protocol ErrorTestService {
    func processData<T>(input: T) -> Int
    var isEnabled: Bool { get }
    var configuration: [String: Any] { get }
}

@Suite(.disabled("Disabled by default to avoid fatal errors during normal test runs"))
struct ErrorMessagingTests {

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
