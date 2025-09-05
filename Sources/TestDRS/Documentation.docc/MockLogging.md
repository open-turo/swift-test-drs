# Mock Logging

Learn how to enable logging to debug and understand mock behavior during tests.

## Overview

TestDRS provides a comprehensive logging system that helps you understand what your mocks are doing during test execution. The logging system tracks mock registration, function calls, stub configuration, and value retrieval, making it easier to debug test failures and understand mock interactions.

## Enabling Logging

### Manual Logging with `withMockLogging`

You can enable logging by wrapping your test operations with `withMockLogging`:

```swift
import TestDRS

func testWeatherService() {
    withMockLogging {
        let mockClient = MockNetworkClient()
        let service = WeatherService(client: mockClient)

        stub(mockClient.fetchData, taking: URL.self, returning: weatherData)
        let result = service.getCurrentWeather()

        // Your test assertions...
    }
}
```

For async tests, use the async version:

```swift
func testAsyncWeatherService() async {
    await withMockLogging {
        let mockClient = MockNetworkClient()
        // Your async test code...
    }
}
```

### Swift Testing Trait Integration

If you're using Swift Testing, you can enable logging with the `.mockLogging` trait:

```swift
import Testing
import TestDRSTestSupport

@Test(.mockLogging)
func testWithLogging() {
    let mock = MockService()
    // Your test code...
}

// Custom identifier
@Test(.mockLogging(identifier: "🔍"))
func testWithCustomIdentifier() {
    // Your test code...
}
```

You can also apply the trait to an entire test suite:

```swift
@Suite(.mockLogging)
struct WeatherServiceTests {

    @Test
    func testFetchWeather() {
        // All tests in this suite will have logging enabled
        let mock = MockNetworkClient()
        // Your test code...
    }

    @Test
    func testErrorHandling() {
        // Logging is automatically enabled for this test too
        let mock = MockNetworkClient()
        // Your test code...
    }
}
```

## Understanding Log Output

When logging is enabled, you'll see output like this:

```
🏎️ Registered MockWeatherService.StubRegistry in testWeatherService()
🏎️ Registered MockWeatherService.BlackBox in testWeatherService()
🏎️ MockWeatherService.StubRegistry setting stub for fetchWeather(location:)
🏎️ MockWeatherService.BlackBox called fetchWeather(location:)
🏎️ MockWeatherService.StubRegistry returning stub for fetchWeather(location:)
```

The log entries show:
- **Registration**: When mock components are created and registered
- **Stub configuration**: When you configure stubs with `stub()`
- **Function calls**: When mock methods are invoked
- **Stub retrieval**: When configured stubs return values

## Multiple Mock Instances

When you have multiple instances of the same mock type, TestDRS automatically numbers them with emoji:

```
🏎️ Registered MockService1️⃣.StubRegistry
🏎️ Registered MockService2️⃣.BlackBox
🏎️ MockService1️⃣.StubRegistry setting stub for process(input:)
🏎️ MockService2️⃣.BlackBox called process(input:)
```

Mocks can be registered outside of the logging scope and will simply be numbered as they are encountered during test execution.

## Customizing the Identifier

You can customize the emoji identifier used in log messages:

```swift
withMockLogging(identifier: "🔍") {
    // Your test code...
}
```

This produces logs like:
```
🔍 MockService.StubRegistry setting stub for getData()
```

## Task-Local Logging Isolation

The logging system uses Swift's task-local values to isolate logs per test. This means that mock interactions occurring in asynchronous code that doesn't use Swift Concurrency (such as callbacks or completion handlers) will not be captured in the logs. Only mock usage within the same task context as the logging scope will be tracked.

## Important: Test Target Dependencies

### Avoid Linking TestDRS Directly

Your test target should **never** link directly to `TestDRS`. Since your app target already links to TestDRS, your test target gets access to TestDRS functionality transitively through the app target.

**Correct Package.swift setup:**

```swift
.testTarget(
    name: "YourTests",
    dependencies: [
        "TestDRSTestSupport",  // Only for test support features like logging traits
        "YourApp"              // Your app target that already links TestDRS
    ]
)
```

**Incorrect setup that causes issues:**

```swift
.testTarget(
    name: "YourTests",
    dependencies: [
        "TestDRS",           // Never link this directly in test targets
        "TestDRSTestSupport"
    ]
)
```

### Xcode Project Configuration

If you're using Xcode projects instead of SwiftPM:

1. Link `TestDRSTestSupport` to your test target only if you need test support features
2. Never link `TestDRS` directly to your test target
3. Your app target should link `TestDRS`

If you see Xcode warnings like:

> Class _TtC7TestDRS[...] is implemented in both [...] and [...].
> One of the two will be used. Which one is undefined.

This indicates you have conflicting dependencies and should remove the direct `TestDRS` dependency from your test target.

## When to Use Logging

Logging is particularly useful when:

- Debugging test failures where mock behavior seems unexpected
- Understanding the order of mock interactions
- Verifying that stubs are being configured and used correctly
- Learning how TestDRS works internally
- Troubleshooting issues with multiple mock instances

The logging output helps you trace exactly what's happening with your mocks during test execution, making it easier to identify issues and verify correct behavior.
