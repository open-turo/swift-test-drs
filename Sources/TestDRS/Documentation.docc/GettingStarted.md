# Getting started with TestDRS

Learn how to use TestDRS to create and use mocks in your Swift unit tests.

## Overview

TestDRS is a powerful Swift testing library that makes it easy to create mock implementations of your protocols, classes, and structs. With TestDRS, you can write tests that isolate the code being tested from its dependencies, making your tests more reliable and focused.

This article will walk you through the basic steps of:
1. Installing TestDRS
2. Creating your first mock
3. Using mocks in your tests
4. Stubbing methods
5. Verifying function calls

## Installation

### Swift Package Manager

Add TestDRS to your project by adding it as a dependency in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/turo/swift-test-drs.git", from: "1.0.0")
]
```

Then add TestDRS to your test target:

```swift
.testTarget(
    name: "YourTests",
    dependencies: ["TestDRS"]
)
```

## Creating your first mock

There are two primary ways to create mocks with TestDRS: using `@AddMock` or `@Mock`. Let's look at both approaches.

### Using @AddMock

The `@AddMock` macro is applied to a production type and generates a mock type alongside it. This is the recommended approach for most cases, as it keeps your mock in sync with your production code.

```swift
import TestDRS

@AddMock
protocol WeatherService {
    func fetchWeather(for city: String) throws -> Weather
    var defaultCity: String { get set }
}
```

This generates a `MockWeatherService` class wrapped in an `#if DEBUG` directive, making it available in test and debug builds but not in release builds.

### Using @Mock

The `@Mock` macro is applied directly to a mock type that you create. This approach allows you to declare a mock in a test target, but requires you to keep the mock in sync with the production code manually. Luckily Xcode will provide a fixit to quickly fill in any missing members required for protocol conformance, so the boilerplate required is still minimal. Of note, you don't write any method bodies or property accessors when using `@Mock`, as the macro generates them for you.

```swift
import TestDRS

@Mock
class MockWeatherService: WeatherService {
    var defaultCity: String
    func fetchWeather(for city: String) throws -> Weather
}
```

### Choosing between @AddMock and @Mock

- Use `@AddMock` when:
  - You want to keep your mock automatically in sync with your production code
  - You want to use your mocks with SwiftUI previews

- Use `@Mock` when:
  - You don't want your mock accessible in your production target, even in debug

## Using mocks in tests

Now that you have a mock, you can use it in your tests. The example below introduces stubbing and verification, which we'll explain in more detail in the following sections:

```swift
import XCTest
import TestDRS
@testable import YourApp

final class WeatherViewModelTests: XCTestCase {
    func testFetchWeather() throws {
        // Create a mock
        let mockWeatherService = MockWeatherService()

        // Create the system under test with the mock
        let viewModel = WeatherViewModel(weatherService: mockWeatherService)

        // Stub the mock
        let expectedWeather = Weather(temperature: 72, condition: .sunny)
        #stub(mockWeatherService.fetchWeather, returning: expectedWeather)

        // Act
        viewModel.loadWeather(for: "San Francisco")

        // Assert
        #expectWasCalled(mockWeatherService.fetchWeather, with: "San Francisco")
        XCTAssertEqual(viewModel.currentWeather, expectedWeather)
    }
}
```

## Stubbing methods

TestDRS provides macros to stub method calls on your mock objects:

### Returning a value

```swift
#stub(mockWeatherService.fetchWeather, taking: String.self, returning: Weather(temperature: 72, condition: .sunny))
```

### Throwing an error

```swift
#stub(mockWeatherService.fetchWeather, taking: String.self, throwing: NetworkError.serverError)
```

### Using a closure

For more complex behavior, you can provide a closure:

```swift
#stub(mockWeatherService.fetchWeather, using: { city in
    if city == "San Francisco" {
        return Weather(temperature: 72, condition: .sunny)
    } else {
        throw NetworkError.notFound
    }
})
```

## Verifying function calls

After running your code under test, you'll often want to verify that certain methods were called with specific parameters:

### Verify a call was made

```swift
#expectWasCalled(mockWeatherService.fetchWeather)
```

### Verify a call was not made

```swift
#expectWasNotCalled(mockWeatherService.fetchWeather)
```

### Checking call counts

You can also verify the number of times a method was called:

```swift
#expectWasCalled(mockWeatherService.fetchWeather)
    .exactlyOnce()
```

```swift
#expectWasCalled(mockWeatherService.fetchWeather)
    .occurring(times: 3)
```

```swift
#expectWasCalled(mockWeatherService.fetchWeather)
    .occurringWithin(times: 2...5)
```

### Verify a call was made with specific arguments

If the input to the method you are testing is Equatable, you can pass those arguments into `#expectWasCalled` in order to verify that the method was called with the expected arguments:
```swift
#expectWasCalled(mockWeatherService.fetchWeather, with: "San Francisco")
```

For methods with multiple arguments, you can pass them as variadic parameters:

```swift
// For a method like: func logEvent(name: String, parameters: [String: Any], count: Int)
#expectWasCalled(mockAnalytics.logEvent, with: "button_click", ["id": "login_button"], 1)
```

If the arguments aren't Equatable, you can instead get the input of the function and then verify the arguments individually:
```swift
// For a method like: func processData(data: CustomData, options: ProcessingOptions)
let result = #expectWasCalled(mockProcessor.processData)
    .exactlyOnce()
let call = try result.getMatchingCall()
let (data, options) = call.input

// Now you can verify the arguments
XCTAssertEqual(data.id, "12345")
XCTAssertTrue(options.preserveMetadata)
```

The `getMatchingCall()` method returns the recorded function call, allowing you to access its `input` property. For methods with multiple parameters, the input is represented as a tuple, which you can destructure to access individual parameters.

## Next steps

Now that you've learned the basics of TestDRS, check out these additional articles:

- <doc:TestingAsynchronousCode> - Learn how to test async functions
- <doc:TestingStaticMembers> - Discover how to test static properties and methods
