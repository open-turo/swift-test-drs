# Getting started with Spies

Learn how to use spies in TestDRS to test code with real implementations while recording interactions.

## Overview

Spies are test doubles that delegate to real implementations while recording all method calls and property accesses. Unlike mocks, which require you to stub behavior, spies use the actual implementation and simply observe what happens.

**When to use spies:**
- You want to test with real implementations but still verify interactions
- You need to ensure the real implementation is being called correctly
- You're testing integration between components with real behavior
- You want to verify side effects of real method calls

**When to use mocks instead:**
- You want to isolate the code under test from dependencies
- You need to control return values or simulate errors
- The real implementation has undesirable side effects (network calls, file I/O, etc.)
- You want faster, more predictable tests

## Creating Spies

### Using @AddSpy

The `@AddSpy` macro is the recommended way to create spies. Apply it to your protocol, class, or struct:

```swift
import TestDRS

@AddSpy
protocol WeatherService {
    func fetchWeather(for city: String) throws -> Weather
}
```

This generates a spy type (e.g., `SpyWeatherService`) that you can use in tests.

### Protocol Spies

Protocol spies wrap a real instance that conforms to the protocol:

```swift
@AddSpy
protocol DataService {
    func save(_ data: Data) throws
    func load() -> Data?
}

// In your tests:
let realService = RealDataService()
let spy = SpyDataService(real: realService)

// Calls delegate to the real service
try spy.save(myData)

// Verify the call was made
#expectWasCalled(spy.save)
```

### Struct Spies

Struct spies also wrap a real instance:

```swift
@AddSpy
struct Calculator {
    func add(_ a: Int, _ b: Int) -> Int {
        return a + b
    }
}

// In your tests:
let realCalculator = Calculator()
let spy = SpyCalculator(real: realCalculator)

// Uses real implementation
let result = spy.add(2, 3)
#expect(result == 5)

// Verify the call
#expectWasCalled(spy.add, with: 2, 3)
```

### Class Spies

Class spies are different - they're **subclasses** that override methods and delegate to `super`:

```swift
@AddSpy
class FileManager {
    func createDirectory(at path: String) throws {
        // Real implementation
    }
}

// In your tests:
let spy = SpyFileManager()  // Note: No real parameter!

// Calls the parent class implementation
try spy.createDirectory(at: "/tmp/test")

// Verify the call
#expectWasCalled(spy.createDirectory, with: "/tmp/test")
```

**Important:** Class spies use the parent class's initializers, not `init(real:)`.

## Using Spies in Tests

Here's a complete example showing how spies fit into your test workflow:

```swift
import Testing
import TestDRS
@testable import YourApp

@AddSpy
protocol Analytics {
    func trackEvent(_ name: String, properties: [String: Any])
}

struct ViewModel {
    let analytics: Analytics

    func handleButtonTap() {
        // Do some work...
        analytics.trackEvent("button_tapped", properties: ["button_id": "submit"])
    }
}

@Test
func testAnalyticsTracking() {
    // Use a real analytics implementation
    let realAnalytics = ProductionAnalytics()
    let spy = SpyAnalytics(real: realAnalytics)

    let viewModel = ViewModel(analytics: spy)

    // Exercise the code
    viewModel.handleButtonTap()

    // Verify the real analytics was called correctly
    #expectWasCalled(spy.trackEvent)
        .exactlyOnce()

    // You can also check the actual arguments
    let result = #expectWasCalled(spy.trackEvent)
    let call = try result.getMatchingCall()
    #expect(call.input.0 == "button_tapped")
}
```

## Verifying Spy Calls

Spies support the same verification macros as mocks:

### Basic verification

```swift
#expectWasCalled(spy.myMethod)
#expectWasNotCalled(spy.myMethod)
```

### Verify call count

```swift
#expectWasCalled(spy.myMethod)
    .exactlyOnce()

#expectWasCalled(spy.myMethod)
    .occurring(times: 3)

#expectWasCalled(spy.myMethod)
    .occurringWithin(times: 2...5)
```

### Verify arguments

```swift
// For Equatable arguments
#expectWasCalled(spy.save, with: myData)

// For non-Equatable arguments
let result = #expectWasCalled(spy.processUser)
let call = try result.getMatchingCall()
#expect(call.input.id == "123")
```

## Spies vs Mocks

| Feature | Spies | Mocks |
|---------|-------|-------|
| Uses real implementation | ✅ Yes | ❌ No |
| Can stub behavior | ❌ No | ✅ Yes |
| Records calls | ✅ Yes | ✅ Yes |
| Verifies interactions | ✅ Yes | ✅ Yes |
| Fast execution | Depends on real implementation | ✅ Yes |
| Requires real dependencies | ✅ Yes | ❌ No |
