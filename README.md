# TestDRS

[![Swift 6.0+](https://img.shields.io/badge/Swift-6.0+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-macOS%20|%20iOS%20|%20tvOS%20|%20watchOS%20|%20macCatalyst-blue.svg)](https://github.com/open-turo/swift-test-drs)
[![License](https://img.shields.io/github/license/open-turo/swift-test-drs)](LICENSE)
[![SwiftPM Compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)

> ⚠️ **Alpha Version**: TestDRS is currently in alpha and the API may change. We welcome feedback and contributions!

**Test DRS** (Dependency Replacement System) is a modern Swift testing library that accelerates your testing velocity with lightning-fast spying, stubbing, and mocking capabilities. Built with Swift macros, TestDRS provides type-safe, compiler-verified test doubles that integrate seamlessly with both XCTest and Swift Testing frameworks.

## Table of contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Core features](#core-features)
  - [Creating mocks](#creating-mocks)
  - [Stubbing methods](#stubbing-methods)
  - [Verifying function calls](#verifying-function-calls)
  - [Testing asynchronous code](#testing-asynchronous-code)
  - [Testing static members](#testing-static-members)
- [Testing patterns](#testing-patterns)
- [Documentation](#documentation)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)

## Features

- ✨ **Zero Boilerplate**: Generate mocks with simple macro annotations
- 🔒 **Type-Safe**: Compile-time verification of mock implementations
- 🏃 **Swift Concurrency**: First-class support for async/await testing
- 🎯 **Flexible**: Mock protocols, classes, and structs
- 🧪 **Framework Agnostic**: Works with XCTest and Swift Testing
- 📋 **Rich Verification**: Comprehensive call verification and parameter matching
- ⚡ **Static Testing**: Isolated mocks of static members
- 🔧 **Debugging**: Clear error messages and debug descriptions

## Requirements

- **Swift**: 6.0 or later
- **Platforms**:
  - macOS 13.0+
  - iOS 16.0+
  - tvOS 13.0+
  - watchOS 6.0+
  - macCatalyst 13.0+

## Installation

### Swift Package Manager

Add TestDRS to your project by adding the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/open-turo/swift-test-drs", from: "X.X.X")
]
```

Then add TestDRS to your app target:

```swift
.target(
    name: "YourAppTarget",
    dependencies: ["TestDRS"]
)
```

> **⚠️ Important ⚠️**: Only link TestDRS to your app target or your test target, never to both! When linking to your app target, your test target will automatically have transitive access to TestDRS through your app target. This prevents duplicate symbol issues that can cause runtime problems. Most users will want to link TestDRS to their app target as that allows for using generated mocks in SwiftUI previews.

### Xcode

1. In Xcode, go to **File → Add Package Dependencies**
2. Enter the repository URL: `https://github.com/open-turo/swift-test-drs`
3. Select your desired version
4. Add TestDRS to your app target (not your test target)

## Quick start

Here's a simple example to get you started with TestDRS:

```swift
import TestDRS
import XCTest

// 1. Add the @AddMock macro to generate a mock
@AddMock
protocol WeatherService {
    func fetchWeather(for city: String) async throws -> Weather
}

// 2. Use the generated mock in your tests
final class WeatherViewModelTests: XCTestCase {
    func testFetchWeather() async throws {
        // Create mock instance
        let mockWeatherService = MockWeatherService()
        let viewModel = WeatherViewModel(weatherService: mockWeatherService)

        // Stub method behavior
        let expectedWeather = Weather(temperature: 72, condition: .sunny)
        #stub(mockWeatherService.fetchWeather, returning: expectedWeather)

        // Execute code under test
        try await viewModel.loadWeather(for: "San Francisco")

        // Verify results and interactions
        XCTAssertEqual(viewModel.currentWeather, expectedWeather)
        #expectWasCalled(mockWeatherService.fetchWeather, with: "San Francisco")
            .exactlyOnce()
    }
}
```

## Core features

### Creating mocks

TestDRS offers two primary approaches for creating mocks:

#### `@AddMock` - Recommended Approach

Apply `@AddMock` to your production types to automatically generate mock implementations:

```swift
@AddMock
protocol NetworkService {
    var timeout: TimeInterval { get set }
    func fetchData(from url: URL) async throws -> Data
}

@AddMock
class DatabaseManager {
    func save(_ data: Data) throws
    func fetch(id: String) -> Data?
}
```

**Benefits:**
- Keeps mocks in sync with production code
- Available in debug builds for SwiftUI previews
- Zero maintenance overhead

#### `@Mock` - Manual Control

Create dedicated mock types in your test target:

```swift
@Mock
class MockNetworkService: NetworkService {
    var timeout: TimeInterval
    func fetchData(from url: URL) async throws -> Data
}
```

**Benefits:**
- Complete control over mock location
- Not included in production target
- Explicit mock definitions

### Stubbing methods

Control mock behavior with powerful stubbing capabilities:

#### Return values

```swift
#stub(mockService.fetchData, returning: expectedData)
#stub(mockService.timeout, returning: 30.0)
```

#### Throwing errors

```swift
#stub(mockService.fetchData, throwing: NetworkError.connectionFailed)
```

#### Dynamic behavior with closures

```swift
#stub(mockService.fetchData, using: { url in
    if url.host == "api.example.com" {
        return mockData
    } else {
        throw NetworkError.invalidURL
    }
})
```

### Verifying function calls

Comprehensive verification of mock interactions:

#### Basic verification

```swift
#expectWasCalled(mockService.fetchData)
#expectWasNotCalled(mockService.deleteData)
```

#### Parameter verification

```swift
#expectWasCalled(mockService.fetchData, with: expectedURL)
#expectWasCalled(mockService.logEvent, with: "user_login", ["id": "123"], 1)
```

#### Call count verification

```swift
// Exactly once
#expectWasCalled(mockService.fetchData).exactlyOnce()

// Specific count
#expectWasCalled(mockService.retry).occurring(times: 3)

// Range
#expectWasCalled(mockService.poll).occurringWithin(times: 2...5)
```

#### Advanced parameter inspection

For non-Equatable parameters, access the actual call data:

```swift
let result = #expectWasCalled(mockService.processComplexData).exactlyOnce()
let call = try result.getMatchingCall()
let (data, options) = call.input

XCTAssertEqual(data.id, "expected-id")
XCTAssertTrue(options.preserveMetadata)
```

### Testing asynchronous code

TestDRS provides first-class support for async/await testing:

#### Direct awaiting (recommended)

```swift
func testAsyncOperation() async throws {
    let mockService = MockAsyncService()
    #stub(mockService.fetchData, returning: expectedData)
    systemUnderTest.service = mockService

    let result = try await systemUnderTest.performOperation()

    #expectWasCalled(mockService.fetchData)
    XCTAssertEqual(result, expectedResult)
}
```

#### Confirmation of calls

For scenarios where you can't directly await operations:

```swift
func testNotificationHandler() async {
    let mockService = MockService()
    let handler = NotificationHandler(service: mockService)

    // Trigger notification
    NotificationCenter.default.post(name: .dataUpdated, object: nil)

    // Wait for async call triggered by notification
    await #confirmationOfCall(to: mockService.processUpdate)
        .exactlyOnce()
}
```

### Testing static members

Test code that uses static methods and properties with proper isolation:

```swift
@AddMock
class Logger {
    static func log(_ message: String, level: LogLevel = .info)
    static var isEnabled: Bool
}

func testLogging() {
    withStaticTestingContext {
        // Configure mock behavior
        #stub(MockLogger.isEnabled, returning: true)
        systemUnderTest.logger = MockLogger.self

        // Test code that uses Logger.log(...)
        systemUnderTest.performAction()

        // Verify static method calls
        #expectWasCalled(MockLogger.log, with: "Action completed", .info)
    }
}
```

## Testing patterns

### Mock closure testing

Test callbacks and completion handlers:

```swift
@Mock
struct CallbackHandler {
    func onComplete(result: Result<Data, Error>)
}

func testCallback() {
    let mockHandler = CallbackHandler()

    dataLoader.loadData(completion: mockHandler.onComplete)

    #expectWasCalled(mockHandler.onComplete)
        .exactlyOnce()
}
```

### Framework compatibility

Works seamlessly with both testing frameworks:

#### XCTest

```swift
import XCTest
import TestDRS

final class MyTests: XCTestCase {
    func testExample() throws {
        // TestDRS code here
    }
}
```

#### Swift Testing

```swift
import Testing
import TestDRS

struct MyTests {
    @Test func example() throws {
        // TestDRS code here
    }
}
```

## Documentation

📚 **[Complete Documentation](https://open-turo.github.io/swift-test-drs/documentation/testdrs/)**

- [Getting Started Guide](https://open-turo.github.io/swift-test-drs/documentation/testdrs/gettingstarted)
- [Testing Asynchronous Code](https://open-turo.github.io/swift-test-drs/documentation/testdrs/testingasynchronouscode)
- [Mocking Static Members](https://open-turo.github.io/swift-test-drs/documentation/testdrs/mockingstaticmembers)
- [FAQ](https://open-turo.github.io/swift-test-drs/documentation/testdrs/faq)

## Examples

The repository includes a small example project demonstrating TestDRS usage:

- **[ExampleClient](ExampleClient/)**

## Contributing

We welcome contributions to TestDRS! Whether you're fixing bugs, adding features, improving documentation, or helping with issues, your contributions are valued.

### Ways to contribute

- **Report bugs** by opening GitHub issues
- **Request features** or suggest improvements
- **Submit code** via pull requests
- **Improve documentation** and examples
- **Help others** by answering questions in issues

### Before contributing

For larger changes, please open an issue first to discuss your approach. This helps ensure your contribution aligns with the project's direction and prevents duplicate work.

### Development setup

1. **Fork** the repository on GitHub
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/swift-test-drs.git
   cd swift-test-drs
   ```
3. **Open** the package in Xcode:
   ```bash
   open Package.swift
   ```

### Code standards

- **Swift style**: Follow standard Swift conventions
- **Testing**: Add tests for new features and bug fixes
- **Documentation**: Document public APIs with DocC comments
- **Compatibility**: Ensure changes work across supported platforms

### Testing

```bash
# Run all tests
swift test

# Run specific test target
swift test --filter TestDRSTests

# Run macro tests
swift test --filter TestDRSMacrosTests
```

### Pull request process

1. **Create** a feature branch (`git checkout -b feature/your-feature`)
2. **Make** your changes with tests
3. **Ensure** all tests pass locally
4. **Commit** with clear, descriptive messages
5. **Push** to your fork (`git push origin feature/your-feature`)
6. **Open** a pull request with:
   - Clear description of changes
   - Link to related issues

### Building documentation

```bash
# Generate DocC documentation
./Scripts/build_docc.sh
```

## License

TestDRS is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

---

**Maintained by [Turo Open Source](https://github.com/open-turo)**

*Accelerate your testing velocity with TestDRS* 🚀
