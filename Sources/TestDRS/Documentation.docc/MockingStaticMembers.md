# Mocking static members

Learn how to test code that uses static members by creating mocks with TestDRS.

## Overview

This article explains how to test code that interacts with static properties and methods by using TestDRS to create mocks. When your code uses types with static members, you can replace those types with TestDRS mocks to verify interactions and control behavior in your tests.

TestDRS provides the `withStaticTestingContext` function to isolate static state between tests, ensuring that each test starts with a clean slate.

This article covers:
1. The challenges of testing with static members
2. Using `withStaticTestingContext` to isolate tests
3. Mocking static methods
4. Verifying static method calls

## The challenge with static members

Static properties and methods in Swift are shared across all instances of a class or struct. This means that changes made in one test can affect other tests:

```swift
class AuthService {
    static var currentUser: User?

    static func isUserLoggedIn() -> Bool {
        return currentUser != nil
    }

    static func currentUserRole() -> String {
        return currentUser?.role ?? "guest"
    }
}

class AuthServiceTests: XCTestCase {
    func testIsUserLoggedIn_WhenUserExists() {
        // This test sets a user
        AuthService.currentUser = User(id: "123", role: "admin")
        XCTAssertTrue(AuthService.isUserLoggedIn())
    }

    func testCurrentUserRole_WhenNoUser() {
        // This assumes no user is set, but might run after the previous test
        // which would cause this test to fail unexpectedly
        XCTAssertEqual(AuthService.currentUserRole(), "guest")
    }
}
```

## Using `withStaticTestingContext`

TestDRS provides `withStaticTestingContext` to isolate static state between tests. This function creates a fresh context for each test, preventing side effects from affecting other tests.

### Basic Usage

Wrap your test logic in a call to `withStaticTestingContext`:

```swift
func testStaticLogger() {
    withStaticTestingContext {
        // Test static members here
        // ...
    }
}
```

### Integrating with XCTest

For test cases that primarily test static members, you can override `invokeTest` to ensure every test method runs in its own static testing context:

```swift
class StaticMemberTests: XCTestCase {
    override func invokeTest() {
        withStaticTestingContext {
            super.invokeTest()
        }
    }

    func testStaticMethod1() {
        // This test now runs in its own static testing context
    }

    func testStaticMethod2() {
        // This test also runs in its own static testing context,
        // unaffected by testStaticMethod1
    }
}
```

## Creating testable static members

To make static members testable with TestDRS, you can simply use one of the macros that generates a mock type, like `@AddMock`:

```swift
@AddMock
class AuthService {
    ...
}
```

The generated `MockAuthService` will conform to `StaticTestable`, allowing you to test its static methods. You can stub and verify calls using the same macros you use for instance members:

```swift
class FeatureManager {
    func canAccessAdminFeature() -> Bool {
        guard AuthService.isUserLoggedIn() else {
            return false
        }

        return AuthService.currentUserRole() == "admin"
    }
}

@Test
func testCanAccessAdminFeature() throws {
    withStaticTestingContext {
        // Set the mock as the dependency
        Dependencies.authService = MockAuthService.self

        // Stub the static methods
        #stub(MockAuthService.isUserLoggedIn, returning: true)
        #stub(MockAuthService.currentUserRole, returning: "admin")

        let featureManager = FeatureManager()

        #expect(featureManager.canAccessAdminFeature())

        // Verify the static methods were called
        #expectWasCalled(MockAuthService.isUserLoggedIn).exactlyOnce()
        #expectWasCalled(MockAuthService.currentUserRole).exactlyOnce()
    }
}
```

## Limitations

The `withStaticTestingContext` function uses TaskLocal values to maintain context, which ensures thread safety within the Swift Concurrency model. However, there are some limitations:

- Detached `Task`s won't inherit the static testing context
- Code running on different threads via GCD or other non-Swift Concurrency mechanisms won't have access to the context

If your code creates detached tasks or uses other threading mechanisms, you will get test failures and/or fatal errors when using static members of a TestDRS mock type.

## Summary

TestDRS makes testing code that uses static members straightforward:

1. Use `withStaticTestingContext` to isolate static state between tests
2. Create mock types with `@AddMock` or `@Mock` that automatically conform to `StaticTestable`
3. Stub and verify static methods using the same macros you use for instance methods

This approach ensures reliable, isolated tests for code that interacts with static members.
