//
// Created on 6/5/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// A protocol that combines stubbing and spying functionality for comprehensive test doubles.
///
/// The `Mock` protocol combines the capabilities of `StubProviding`, `Spy`, and `StaticTestable` protocols
/// to create a versatile test double that can:
/// 
/// 1. Stub method and property implementations to return predetermined values (`StubProviding`)
/// 2. Record and verify method invocations, including parameters and call counts (`Spy`)
/// 3. Support testing of static members in a thread-safe manner (`StaticTestable`)
///
/// Mock objects created with this protocol are suitable for both state-based and interaction-based testing approaches.
/// They allow you to verify both the behavior of the code under test (by examining calls made to the mock)
/// and its outputs (by controlling what the mock returns).
///
/// Mock implementations are typically generated automatically using the `@AddMock` macro, which creates
/// a concrete class that implements this protocol for a given type (protocol, class, or struct).
///
/// Example usage:
/// ```swift
/// @AddMock
/// protocol Calculator {
///     func add(_ a: Int, _ b: Int) -> Int
/// }
///
/// func testCalculatorUsage() {
///     let mockCalculator = MockCalculator()
///
///     // Always return 42 from the add method, no matter the input
///     #stub(mockCalculator.add, returning: 42)
///     
///     // Use the mock in your code under test
///     let result = systemUnderTest.performCalculation(using: mockCalculator)
///     
///     // Verify the mock was called correctly
///     #expectWasCalled(mockCalculator.add, with: 10, 20)
///     XCTAssertEqual(result, 42)
/// }
/// ```
public protocol Mock: StubProviding, Spy, StaticTestable {}
