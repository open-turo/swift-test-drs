# Testing asynchronous code

Learn best practices for testing asynchronous Swift code with TestDRS.

## Overview

Modern Swift applications commonly use asynchronous programming with `async/await` for operations like network requests, database access, and other potentially long-running tasks. Testing asynchronous code presents unique challenges, but TestDRS provides solutions to make it straightforward. This article will guide you through testing asynchronous code and verifying expectations using TestDRS.

## Prefer direct awaiting when possible

The most straightforward way to test asynchronous code is to make your test functions async and directly await the operations:

```swift
func testFetchWeather() async throws {
    // Arrange
    let mockWeatherService = MockWeatherService()
    let expectedWeather = Weather(temperature: 72, condition: .sunny)
    #stub(mockWeatherService.fetchWeather, with: "San Francisco", returning: expectedWeather)
    
    let viewModel = WeatherViewModel(weatherService: mockWeatherService)
    
    // Act - directly await the async operation
    try await viewModel.loadWeather(for: "San Francisco")
    
    // Assert
    XCTAssertEqual(viewModel.currentWeather, expectedWeather)
    #expectWasCalled(mockWeatherService.fetchWeather, with: "San Francisco")
}
```

### Common mistake: Unnecessary use of Task

A common mistake is wrapping async calls in a `Task` when it's not necessary:

```swift
// ❌ INCORRECT: Unnecessarily using Task
func testFetchWeather() throws {
    let mockWeatherService = MockWeatherService()
    let viewModel = WeatherViewModel(weatherService: mockWeatherService)
    
    // This creates a Task but doesn't wait for it to complete
    Task {
        try await viewModel.loadWeather(for: "San Francisco")
    }
    
    // ⚠️ This assertion might run before the Task completes
    #expectWasCalled(mockWeatherService.fetchWeather, with: "San Francisco")
}

// ✅ CORRECT: Simply make the test async
func testFetchWeather() async throws {
    let mockWeatherService = MockWeatherService()
    let viewModel = WeatherViewModel(weatherService: mockWeatherService)
    
    // Directly await the async operation
    try await viewModel.loadWeather(for: "San Francisco")
    
    // This assertion runs after the async operation completes
    #expectWasCalled(mockWeatherService.fetchWeather, with: "San Francisco")
}
```

### Refactoring production code for testability

Sometimes, you might need to refactor your production code to make it more testable. For example, if your code dispatches work to background tasks, consider exposing an async function that can be directly awaited:

```swift
// ❌ HARD TO TEST: Fire-and-forget Task creation
class WeatherViewModel {
    func loadWeatherInBackground(for city: String) {
        Task {
            do {
                let weather = try await weatherService.fetchWeather(for: city)
                self.currentWeather = weather
            } catch {
                self.error = error
            }
        }
    }
}

// ✅ EASIER TO TEST: Expose an async function
class WeatherViewModel {
    func loadWeather(for city: String) async {
        do {
            let weather = try await weatherService.fetchWeather(for: city)
            self.currentWeather = weather
        } catch {
            self.error = error
        }
    }
    
    // Keep the fire-and-forget method, but have it call the async method
    func loadWeatherInBackground(for city: String) {
        Task {
            await loadWeather(for: city)
        }
    }
}
```

## When to use `#confirmationOfCall`

While direct awaiting is preferable, there are scenarios where you can't directly await an operation:

1. Testing code that uses timers or debouncing
2. Testing event-driven systems (like Combine publishers)
3. Testing callbacks from notification systems
4. Testing code that creates detached tasks you can't await
5. Testing asynchronous UI interactions

In these cases, `#confirmationOfCall` provides a way to asynchronously wait for and verify function calls.

### Example: Testing notification observers

```swift
class NetworkMonitor {
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func appDidBecomeActive() {
        Task {
            try? await networkClient.checkConnectivity()
        }
    }
}

// Testing with confirmationOfCall
func testNetworkMonitorChecksConnectivityWhenAppBecomesActive() async {
    // Arrange
    let mockNetworkClient = MockNetworkClient()
    let monitor = NetworkMonitor(networkClient: mockNetworkClient)
    
    // Act - post the notification
    NotificationCenter.default.post(
        name: UIApplication.didBecomeActiveNotification,
        object: nil
    )
    
    // Assert - wait for the async call triggered by the notification
    await #confirmationOfCall(to: mockNetworkClient.checkConnectivity)
}
```

## Controlling time limits

By default, `#confirmationOfCall` will wait an infinite time, but you can specify a custom time limit:

```swift
// Wait up to 5 seconds for a long-running operation
await #confirmationOfCall(to: mockLongRunningService.process, timeLimit: .seconds(5))
```

## Verifying the number of calls

On its own, `#confirmationOfCall` waits for a single call. Just as with `expectWasCalled` though, you can verify multiple calls using `occurring` and `occurringWithin`:

```swift
// Confirm the function was called exactly 3 times
await #confirmationOfCall(to: mockClient.fetchData)
    .occurring(times: 3)
    
// Confirm the function was called between 2 and 5 times
await #confirmationOfCall(to: mockClient.fetchData)
    .occurringWithin(times: 2...5)
```

You can also use `exactlyOnce` to verify that additional calls were not made:

```swift
// Confirm the function was called exactly once
await #confirmationOfCall(to: mockClient.fetchData)
    .exactlyOnce()
```

Note that for any of these methods, additional calls may be made after the test is finished without causing a failure.
This is because these methods do not introduce any sort of artificial delay in order to wait for a failure to occur.

## Summary

Testing asynchronous code using TestDRS is straightforward when following these principles:
1. Directly await async operations whenever possible
2. Refactor production code to make it more testable when needed
3. Use `confirmationOfCall` only when you can't directly await the operation

By following these guidelines, you can write reliable tests for even complex asynchronous behavior in your Swift applications.
