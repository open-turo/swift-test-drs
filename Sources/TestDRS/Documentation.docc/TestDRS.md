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

### Creating test doubles

Test doubles are objects that stand in for real objects in your tests. This section covers how to create mocks that you can use to test your code in isolation.

- ``AddMock()``
- ``Mock()``

### Stubbing methods

Once you have a mock, you can control how it behaves by stubbing its methods to return specific values or throw errors.

- ``stub(_:taking:returning:)``
- ``stub(_:taking:throwing:)``
- ``stub(_:using:)``

### Verifying interactions

After running your code under test, you'll often want to verify that it interacted with your mock in the expected way.

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
