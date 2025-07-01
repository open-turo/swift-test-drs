//
// Created on 7/1/25.
// Copyright © 2025 Turo Open Source. All rights reserved.
//

import Foundation
import TestDRS
import Testing

struct NonSendableInputTests {

    @Test
    func confirmationOfCall_WithNonSendableInput_Compiles() async {
        let mockObject = MockObject()
        mockObject.processTimer(Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in }))

        // This test verifies that confirmationOfCall works with non-Sendable input types like Timer
        // The focus is on compilation, not runtime behavior
        await #confirmationOfCall(to: mockObject.processTimer).exactlyOnce()
    }

}

// MARK: - Test Types

/// A mock object for testing non-Sendable input handling
@Mock
private struct MockObject {

    /// A method that takes a Timer (non-Sendable) parameter
    func processTimer(_ timer: Timer)

}
