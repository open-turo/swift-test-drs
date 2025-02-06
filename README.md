>⚠️ **Warning:** Test DRS is still in alpha and the API could change at any time!

# Test DRS
Accelerate your testing velocity with Test DRS: Swift utilities for lightning-fast spying, stubbing, and mocking.

## Installation

To install Test DRS, add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/open-turo/swift-test-drs", from: "X.X.X")
]
```

Then, add `TestDRS` as a dependency for your target:

```swift
.target(
    name: "YourTargetName",
    dependencies: ["TestDRS"]
)
```

## Getting Started

### Creating Mocks

Generating mock types for testing is as simple as adding the `@AddMock` macro to a type that you would like to mock:

```
@AddMock
protocol NetworkClientProtocol {
    func get(url: URL) throws -> Data
}
```

This generates a mock with the prefix "Mock" so in this case the generated mock type would be `MockNetworkClientProtocol`.

> **Note:** While the above example is adding a type to a protocol, you can also add mocks to classes and structs. In the case of a class, the generated mock is a subclass of the class you add the mock to. When attached to a struct, a new mock struct is created. Mocking a struct can be useful in cases where you can't add the `@AddMock` macro to a protocol definition or when you need a mock that conforms to multiple protocols.

### Stubbing Functions

Once you have a mock type, you can stub its methods to return some mock data:

```swift
#stub(networkClient.get, returning: data)
```

If a method is called in a test before being stubbed, a fatal error will be thrown.


### Expecting Function Calls

Once you have stubbed methods in your mock type, you can use the mock to perform some unit of work that you are trying to test. Then to verify expectations, you can use `#expectWasCalled` which works similarly to `#expect` from SwiftTesting:

```swift
#expectWasCalled(networkClient.get, with: expectedURL)
```

`#expectWasCalled` returns a `ExpectWasCalledResult` which you can use to verify the number of matching function calls:

```swift
#expectWasCalled(networkClient.get, with: expectedURL)
    .exactlyOnce()
```

### Example Test Case

Here is a complete example of a test case using Test DRS with an `XCTestCase`:

```swift
import TestDRS
import XCTest

final class WeatherServiceTests: XCTestCase {

    func testFetchingWeather() throws {
        let networkClient = MockNetworkClientProtocol()
        let dataParser = MockDataParserProtocol()
        let weatherService = WeatherServiceStruct(networkClient: networkClient, dataParser: dataParser)

        let data = try XCTUnwrap("Hello World".data(using: .utf8))
        let expectedURL = try XCTUnwrap(URL(string: "https://api.weather.com/v1/location/charleston/forecast/daily/5day.json"))

        #stub(networkClient.get, returning: data)
        #stub(dataParser.parse, returning: Weather(temperature: 72, description: "Sunny"))

        let weather = try weatherService.fetchWeather(for: "charleston")

        XCTAssertEqual(weather.temperature, 72)
        XCTAssertEqual(weather.description, "Sunny")

        #expectWasCalled(networkClient.get, with: expectedURL)
            .exactlyOnce()

        #expectWasCalled(dataParser.parse, with: data, returning: Weather.self)
            .exactlyOnce()
    }

}
```

Test DRS is also fully compatible with `SwiftTesting`:

```swift
import TestDRS
import Testing

struct WeatherServiceSwiftTesting {

    @Test
    func testFetchingWeather() throws {
        let networkClient = MockNetworkClientProtocol()
        let dataParser = MockDataParserProtocol()
        let weatherService = WeatherServiceStruct(networkClient: networkClient, dataParser: dataParser)

        let data = try #require("Hello World".data(using: .utf8))
        let expectedURL = try #require(URL(string: "https://api.weather.com/v1/location/charleston/forecast/daily/5day.json"))

        #stub(networkClient.get, returning: data)
        #stub(dataParser.parse, returning: Weather(temperature: 72, description: "Sunny"))

        let weather = try weatherService.fetchWeather(for: "charleston")

        #expect(weather.temperature == 72)
        #expect(weather.description == "Sunny")

        #expectWasCalled(networkClient.get, with: expectedURL)
            .exactlyOnce()

        #expectWasCalled(dataParser.parse, with: data, returning: Weather.self)
            .exactlyOnce()
    }

}
```


For more examples, see the tests within the ExampleClient included in this repository.
