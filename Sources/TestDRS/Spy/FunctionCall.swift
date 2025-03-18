//
// Created on 4/29/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// A protocol that represents a function call.
///
/// This protocol creates a common interface for function calls while preserving
/// the generic type information about the input and output types.
/// It enables storing different function calls in the same collection (as `[any FunctionCallRepresentation]`).
///
/// This is primarily an internal implementation detail of the spy system, which allows
/// the recording and verification of function calls.
protocol FunctionCallRepresentation: CustomDebugStringConvertible, Identifiable {

    /// The input type of the function call.
    associatedtype Input

    /// The output type of the function call.
    associatedtype Output

    /// The signature of the function as captured by `#function`, e.g., `foo(bar:)`.
    var signature: FunctionSignature { get }

    /// The input parameter(s) passed to the function when it was called.
    ///
    /// For functions without parameters, this will be `Void()`.
    /// For functions with multiple parameters, this will be a tuple containing all parameters.
    var input: Input { get }

    /// The return type of the function.
    var outputType: Output.Type { get }

    /// The time at which the function was called.
    var time: Date { get }

    /// A unique identifier for this function call.
    var id: Int { get }

}

extension FunctionCallRepresentation {
    public var debugDescription: String {
        """
        ******* Function Call \(id) *******
        signature: \(signature)
        input: \(input)
        outputType: \(outputType)
        time: \(FunctionCallUtilities.dateFormatter.string(from: time))
        """
    }
}

/// Utility functions and properties for function call handling.
private enum FunctionCallUtilities {
    /// A date formatter used for consistent timestamp formatting in debug descriptions.
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd H:mm:ss.SSS"
        return dateFormatter
    }()
}

/// A concrete implementation of `FunctionCallRepresentation` that captures a function call's details.
///
/// This struct represents a single function call, storing information about what function was called,
/// with what parameters, and when it was called. It's used by the spy system to record function calls
/// so they can be verified later in tests.
///
/// - Note: This struct is marked as `@unchecked Sendable` even though the `input` might not actually be `Sendable`.
/// The risk is minimal since this is designed to be used with tests and SwiftUI previews.
public struct FunctionCall<Input, Output>: FunctionCallRepresentation, @unchecked Sendable {

    /// The signature of the function as captured by `#function`, e.g., `foo(bar:)`.
    public let signature: FunctionSignature

    /// The input parameter(s) passed to the function when it was called.
    ///
    /// For functions without parameters, this will be `Void()`.
    /// For functions with multiple parameters, this will be a tuple containing all parameters.
    public let input: Input

    /// The return type of the function.
    let outputType: Output.Type

    /// The time at which the function was called.
    let time: Date

    /// A unique identifier for this function call.
    public let id: Int

}
