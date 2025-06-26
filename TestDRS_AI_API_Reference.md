# TestDRS AI-Friendly API Reference

TestDRS is a Swift testing library that provides powerful mocking, stubbing, and verification capabilities through Swift macros. This comprehensive reference covers all publicly available interfaces for writing tests.

## Installation

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/open-turo/swift-test-drs", from: "X.X.X")
]

.testTarget(
    name: "YourTests",
    dependencies: ["TestDRS"]
)
```

## Core Concepts

- **Mocks**: Test doubles that record function calls and can be stubbed
- **Stubbing**: Pre-defining return values or behaviors for mock methods
- **Spying**: Recording and verifying function calls and their parameters
- **Static Testing**: Isolated testing of static members with proper context isolation

## Mock Creation APIs

### @AddMock Macro
**Purpose**: Generates mock types alongside production types
**Syntax**: `@AddMock`
**Generated Type**: `Mock{TypeName}`

```swift
@AddMock
protocol NetworkClient {
    func fetchData(url: URL) async throws -> Data
    var timeout: TimeInterval { get set }
}
// Generates: MockNetworkClient
```

**Rules**:
- Classes → subclass mocks
- Protocols/structs → separate mock implementations
- Private/final members excluded
- Generated mocks wrapped in `#if DEBUG`

### @Mock Macro
**Purpose**: Adds mock functionality to existing mocked types
**Syntax**: `@Mock`
**Usage**: Applied to struct/class definitions

```swift
@Mock
class MockNetworkClient: NetworkClient {
    var timeout: TimeInterval
    func fetchData(url: URL) async throws -> Data
    // No implementation needed - macro generates it
}
```

## Stubbing APIs

### #stub(_:taking:returning:)
**Purpose**: Set function to return specific value
**Syntax**: `#stub(function, taking: InputType.self, returning: returnValue)`

```swift
#stub(mockClient.fetchData, taking: URL.self, returning: mockData)
```

### #stub(_:taking:throwing:)
**Purpose**: Set function to throw specific error
**Syntax**: `#stub(function, taking: InputType.self, throwing: error)`

```swift
#stub(mockClient.fetchData, taking: URL.self, throwing: NetworkError.timeout)
```

### #stub(_:using:)
**Purpose**: Set function to use closure for dynamic responses
**Syntax**: `#stub(function, using: closure)`

```swift
#stub(mockClient.fetchData, using: { url in
    if url.host == "api.example.com" {
        return validData
    } else {
        throw NetworkError.invalidHost
    }
})
```

### Property Stubbing
```swift
// Stub property values
#stub(mockClient.timeout, returning: 30.0)
```

## Verification APIs

### #expectWasCalled(_:taking:returning:mode:)
**Purpose**: Verify function was called
**Syntax**: `#expectWasCalled(function, taking: InputType.self, returning: OutputType.self, mode: ExpectedCallMode = .nonExclusive)`
**Returns**: `ExpectWasCalledResult<AmountMatching, Input, Output>`

```swift
#expectWasCalled(mockClient.fetchData, taking: URL.self, returning: Data.self)
```

### #expectWasCalled(_:with:returning:mode:)
**Purpose**: Verify function called with specific input (requires `Equatable` input)
**Syntax**: `#expectWasCalled(function, with: expectedInput, returning: OutputType.self, mode: ExpectedCallMode = .nonExclusive)`

```swift
let expectedURL = URL(string: "https://api.example.com")!
#expectWasCalled(mockClient.fetchData, with: expectedURL, returning: Data.self)
```

### #expectWasNotCalled(_:taking:returning:)
**Purpose**: Verify function was NOT called
**Syntax**: `#expectWasNotCalled(function, taking: InputType.self, returning: OutputType.self)`

```swift
#expectWasNotCalled(mockClient.fetchData, taking: URL.self, returning: Data.self)
```

### ExpectedCallMode
**Cases**:
- `.exclusive`: Non-matching calls cause failure
- `.nonExclusive`: Non-matching calls allowed (default)

## Async Testing APIs

### #confirmationOfCall(to:taking:returning:timeLimit:isolation:)
**Purpose**: Asynchronously wait for function call confirmation
**Syntax**: `#confirmationOfCall(to: function, taking: InputType.self, returning: OutputType.self, timeLimit: Duration? = nil, isolation: isolated (any Actor)? = #isolation)`
**Returns**: `FunctionCallConfirmation<AmountMatching, Input, Output>`

```swift
await #confirmationOfCall(to: mockClient.fetchData, taking: URL.self, returning: Data.self)
```

### #confirmationOfCall(to:with:returning:timeLimit:isolation:)
**Purpose**: Asynchronously wait for call with specific input
**Syntax**: `#confirmationOfCall(to: function, with: expectedInput, returning: OutputType.self, timeLimit: Duration? = nil, isolation: isolated (any Actor)? = #isolation)`

```swift
await #confirmationOfCall(to: mockClient.fetchData, with: expectedURL, returning: Data.self, timeLimit: .seconds(5))
```

## Static Testing APIs

### withStaticTestingContext(operation:)
**Purpose**: Creates isolated context for testing static members
**Syntax**: `withStaticTestingContext { /* test code */ }`

```swift
func testStaticMethod() {
    withStaticTestingContext {
        #stub(MockService.staticMethod, returning: "test")
        let result = ProductionCode.useStaticMethod()
        #expectWasCalled(MockService.staticMethod)
    }
}
```

### XCTest Integration
```swift
class StaticMemberTests: XCTestCase {
    override func invokeTest() {
        withStaticTestingContext {
            super.invokeTest()
        }
    }

    func testStaticBehavior() {
        // All test methods run in isolated static context
    }
}
```

## Core Protocols

### Mock Protocol
**Inherits**: `StubProviding`, `Spy`, `StaticTestable`, `CustomDebugStringConvertible`
**Purpose**: Complete test double with stubbing and spying capabilities

### StubProviding Protocol
**Key Methods**:
- `setStub(for:withSignature:taking:returning:)` - Set return value stub
- `setStub(for:withSignature:taking:throwing:)` - Set throwing stub
- `setDynamicStub(for:withSignature:using:)` - Set closure-based stub
- `setStub(value:forPropertyNamed:)` - Set property stub
- `stubOutput(for:signature:)` - Get stubbed output
- `throwingStubOutput(for:signature:)` - Get stubbed output (may throw)
- `stubValue(for:)` - Get stubbed property value

**Properties**: `stubRegistry: StubRegistry`

### Spy Protocol
**Key Methods**:
- `recordCall(with:at:returning:signature:)` - Record function call
- `expectWasCalled(_:withSignature:taking:returning:mode:)` - Verify calls
- `expectWasCalled(_:withSignature:expectedInput:returning:mode:)` - Verify calls with input
- `expectWasNotCalled(_:withSignature:taking:returning:)` - Verify no calls
- Static versions: `expectStaticFunctionWasCalled`, `expectStaticFunctionWasNotCalled`

**Properties**: `blackBox: BlackBox`

### StaticTestable Protocol
**Key Method**: `register(with:)` - Register with static testing context

## Result Types

### ExpectWasCalledResult<AmountMatching, Input, Output>
**Purpose**: Result of expectWasCalled operations with verification methods

**Properties**:
- `matchingCall` (for `MatchingSingle`)
- `matchingCalls` (for `MatchingMultiple`)

**Methods**:
- `getMatchingCall()` - Get single matching call (throws if not exactly one)
- `getFirstMatchingCall()` - Get first matching call
- `getLastMatchingCall()` - Get last matching call
- `exactlyOnce()` - Verify called exactly once
- `occurring(times: Int)` - Verify called specific number of times
- `occurringWithin(times: any LowerBoundProviding)` - Verify called within range

```swift
let result = #expectWasCalled(mockClient.fetchData, with: url)
    .exactlyOnce()
let call = try result.getMatchingCall()
let input = call.input // Access the URL parameter
```

### FunctionCallConfirmation<AmountMatching, Input, Output>
**Purpose**: Result of confirmationOfCall operations (async version of ExpectWasCalledResult)
**Methods**: Same verification methods as ExpectWasCalledResult

```swift
let confirmation = await #confirmationOfCall(to: mockClient.fetchData)
    .occurring(times: 3)
```

## Supporting Types

### FunctionCall<Input, Output>
**Purpose**: Represents a recorded function call
**Properties**:
- `signature: FunctionSignature` - Function identifier
- `input: Input` - Call parameters
- `id: UUID` - Unique call identifier
- `time: Date` - When call was made

### FunctionSignature
**Purpose**: Identifies functions for stubbing and verification
**Conformances**: `Equatable`, `Hashable`, `Sendable`, `ExpressibleByStringLiteral`
**Properties**:
- `text: String` - Human-readable signature
- `name: String` - Function name
- `isAbbreviated: Bool` - Whether signature is shortened

**Operators**: `~=` for pattern matching

### BlackBox
**Purpose**: Records and manages function call history
**Conformances**: `CustomDebugStringConvertible`
**Key Methods**: `recordCall`, `callsMatching`, async stream methods

### StubRegistry
**Purpose**: Stores and manages function and property stubs
**Conformances**: `CustomDebugStringConvertible`

## Amount Matching Types

### Base Protocol
- `FunctionCallAmountMatching` - Base protocol for call amount matching

### Concrete Types
- `MatchingSingle` - For single call operations (getMatchingCall available)
- `MatchingMultiple` - For multiple call operations (getMatchingCalls available)
- `MatchingFirst` - Match first call only
- `MatchingOne` - Match exactly one call
- `MatchingSomeAmount` - Match specific count/range
- `MatchingAnyAmount` - Match any number of calls

## Usage Patterns

### Complete XCTest Example
```swift
import TestDRS
import XCTest

final class WeatherServiceTests: XCTestCase {
    func testFetchingWeather() throws {
        // Arrange
        let networkClient = MockNetworkClientProtocol()
        let dataParser = MockDataParserProtocol()
        let weatherService = WeatherService(networkClient: networkClient, dataParser: dataParser)

        let data = try XCTUnwrap("Hello World".data(using: .utf8))
        let expectedURL = try XCTUnwrap(URL(string: "https://api.weather.com/forecast"))

        // Stub
        #stub(networkClient.get, returning: data)
        #stub(dataParser.parse, returning: Weather(temperature: 72, description: "Sunny"))

        // Act
        let weather = try weatherService.fetchWeather(for: "charleston")

        // Assert
        XCTAssertEqual(weather.temperature, 72)
        XCTAssertEqual(weather.description, "Sunny")

        #expectWasCalled(networkClient.get, with: expectedURL)
            .exactlyOnce()
        #expectWasCalled(dataParser.parse, with: data, returning: Weather.self)
            .exactlyOnce()
    }
}
```

### Complete SwiftTesting Example
```swift
import TestDRS
import Testing

struct WeatherServiceTests {
    @Test
    func fetchingWeather() throws {
        // Arrange
        let networkClient = MockNetworkClientProtocol()
        let dataParser = MockDataParserProtocol()
        let weatherService = WeatherService(networkClient: networkClient, dataParser: dataParser)

        let data = try #require("Hello World".data(using: .utf8))
        let expectedURL = try #require(URL(string: "https://api.weather.com/forecast"))

        // Stub
        #stub(networkClient.get, returning: data)
        #stub(dataParser.parse, returning: Weather(temperature: 72, description: "Sunny"))

        // Act
        let weather = try weatherService.fetchWeather(for: "charleston")

        // Assert
        #expect(weather.temperature == 72)
        #expect(weather.description == "Sunny")

        #expectWasCalled(networkClient.get, with: expectedURL)
            .exactlyOnce()
        #expectWasCalled(dataParser.parse, with: data, returning: Weather.self)
            .exactlyOnce()
    }
}
```

### Async Testing Example
```swift
@Test
func asyncNetworkCall() async throws {
    let mockClient = MockNetworkClient()
    let service = DataService(client: mockClient)

    #stub(mockClient.fetchData, returning: mockData)

    // Direct await - preferred approach
    let result = try await service.processData()

    #expectWasCalled(mockClient.fetchData)
        .exactlyOnce()
}

@Test
func asyncCallbackTesting() async {
    let mockClient = MockNetworkClient()
    let monitor = NetworkMonitor(client: mockClient)

    // Trigger async callback
    NotificationCenter.default.post(name: .networkStatusChanged, object: nil)

    // Wait for async call
    await #confirmationOfCall(to: mockClient.checkStatus)
        .exactlyOnce()
}
```

### Testing Closures
```swift
// Create mock for closure testing
@Mock
struct CallbackHandler {
    func onComplete(result: Result<Data, Error>)
}

@Test
func closureIsCalled() {
    let mockCallback = CallbackHandler()
    let dataLoader = DataLoader()

    // Pass mock's function as completion handler
    dataLoader.loadData(completion: mockCallback.onComplete)

    #expectWasCalled(mockCallback.onComplete)
        .exactlyOnce()
}
```

### Non-Equatable Parameter Testing
```swift
@Test
func nonEquatableParameters() throws {
    let mockProcessor = MockDataProcessor()
    let service = ProcessingService(processor: mockProcessor)

    service.processComplexData(CustomData(id: "123"), options: ProcessingOptions())

    let result = #expectWasCalled(mockProcessor.processComplexData).exactlyOnce()
    let call = try result.getMatchingCall()
    let (data, options) = call.input

    XCTAssertEqual(data.id, "123")
    XCTAssertTrue(options.preserveMetadata)
}
```

## Best Practices

### Async Testing Guidelines
1. **Prefer direct awaiting**: Make test functions async and directly await operations
2. **Avoid unnecessary Task wrapping**: Don't wrap async calls in Task unless needed
3. **Use #confirmationOfCall for**: Timers, event-driven systems, notification callbacks, detached tasks
4. **Refactor for testability**: Expose async functions that can be directly awaited

### Static Testing Guidelines
1. **Use withStaticTestingContext**: Wrap static member tests for isolation
2. **Override invokeTest**: For test classes primarily testing static members
3. **Limitations**: Detached Tasks and non-Swift Concurrency threading won't inherit context

### General Guidelines
1. **Create new mocks per test**: Don't reuse mocks between tests
2. **Stub before acting**: Always stub methods before calling code under test
3. **Verify after acting**: Use expectWasCalled after exercising code
4. **Fatal errors on unstubbed calls**: Unstubbed method calls will cause fatal errors

## Troubleshooting

### Common Issues
- **Unstubbed method fatal error**: Always stub methods before they're called
- **Static context issues**: Use withStaticTestingContext for static member testing
- **Async test race conditions**: Use direct await instead of Task wrapping
- **Missing call verifications**: Ensure expectations are checked after code execution

### Debug Support
All types provide `CustomDebugStringConvertible` for rich debugging information including:
- Mock state and registered stubs
- Call history with timestamps
- Function signatures and parameters
