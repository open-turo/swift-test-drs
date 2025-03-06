# Frequently Asked Questions

Common questions and answers about using TestDRS.

## How do I test that a closure was called?

Since closures are just unnamed functions in Swift, you can create a mock type to stand in for your closure:

```swift
// Step 1: Create a mock to stand in for your closure
@Mock
struct CallbackHandler {
    func onComplete(result: Result<Data, Error>)
}

// Step 2: Use the mock in your test
func testClosureIsCalled() {
    // Arrange
    let mockCallback = CallbackHandler()
    let dataLoader = DataLoader()
    
    // Act - pass the mock's function directly as the completion handler
    dataLoader.loadData(completion: mockCallback.onComplete)
    
    // Assert
    #expectWasCalled(mockCallback.onComplete)
        .exactlyOnce()
}
```

## How do I verify the arguments of non-Equatable types?

When dealing with non-Equatable types, you can use ``getMatchingCall()`` to access the function call and examine its input:

```swift
// Access a single call
let result = #expectWasCalled(mockProcessor.processComplexData).exactlyOnce()
let call = try result.getMatchingCall()

// Destructure the input into the individual arguments
let (id, metadata) = call.input

// Assert on those arguments
XCTAssertEqual(id, "expected-id")
XCTAssertTrue(metadata.contains("important-flag"))
```

See ``ExpectWasCalledResult`` for additional methods for accessing function calls.

## Is there a way to reset mock history between test cases?

TestDRS does not currently have a way to reset a mock. Generally, you should create a new mock instance for each test. If you find yourself wanting to reset a mock during a test, consider if that test should be refactored into multiple tests.

For static mocks, use `withStaticTestingContext` to isolate test cases, as described in the <doc:TestingStaticMembers> article.
