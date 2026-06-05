# ``TestDRS``

A modern Swift testing library that provides powerful mocking, stubbing, and verification capabilities through Swift macros.

## Overview

TestDRS simplifies writing unit tests by generating test doubles (mocks) that you can use to isolate your code from its dependencies. It leverages Swift macros to reduce boilerplate and provide a type-safe, compiler-verified testing experience.

With TestDRS, you can:

- Create mock implementations of protocols, classes, and structs
- Stub function returns with specific values or dynamic behavior
- Verify that functions were called with the expected parameters
- Test asynchronous code with async/await support
- Test code using static members with proper isolation between tests

## Topics

### Getting started

- <doc:GettingStarted>
- <doc:GettingStartedWithSpies>

### Creating test doubles

TestDRS provides two types of test doubles: **mocks** that allow you to stub behavior, and **spies** that delegate to real implementations. Both support call recording and verification.

#### Generating test doubles from existing types

Apply these macros to your protocols, classes, or structs to automatically generate test doubles. The generated types are wrapped in `#if DEBUG` so they're available in tests and debug builds but not in production.

- ``AddMock()`` - Generates a mock (e.g., `MockUserService` from `UserService`) that you can stub and verify
- ``AddSpy()`` - Generates a spy (e.g., `SpyUserService` from `UserService`) that wraps or inherits from the real implementation

#### Creating test doubles manually

Apply these macros to test double types you define yourself, giving you more control over where the test double lives.

- ``Mock()`` - Marks a manually created type as a mock, generating the necessary stubbing and verification infrastructure

### Stubbing behavior

Control how your mocks behave by stubbing their methods to return specific values or throw errors. Note: Spies always delegate to real implementations and cannot be stubbed.

- ``stub(_:taking:returning:)``
- ``stub(_:taking:throwing:)``
- ``stub(_:using:)``

### Verifying interactions

Verify that your test doubles (mocks or spies) were called as expected during your tests.

- ``expectWasCalled(_:taking:returning:mode:)``
- ``expectWasCalled(_:with:returning:mode:)``
- ``expectWasNotCalled(_:taking:returning:)``
- ``ExpectWasCalledResult``

### Value and state verification

Verify that values match expected patterns or enum cases.

- ``expectCase(_:in:)``

### Asynchronous testing

These tools help you test asynchronous code by allowing you to await and verify function calls that might happen in the future.
- <doc:TestingAsynchronousCode>
- ``confirmationOfCall(to:taking:returning:timeLimit:isolation:)``
- ``confirmationOfCall(to:with:returning:timeLimit:isolation:)``
- ``FunctionCallConfirmation``

### Debugging and observability

- <doc:MockLogging>

### Additional testing topics

- <doc:MockingStaticMembers>
- <doc:FAQ>
