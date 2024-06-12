//
// Created on 6/12/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

extension StubRegistry {

    enum StubError: Error {
        /// There was no stub registered for the function when attempting to retrieve a stub.
        case noStub
        /// This would indicate an issue with the `StubProviding` protocol or the `StubRegistry`.
        case incorrectOutputType
        /// This would indicate an issue with the `StubProviding` protocol or the `StubRegistry`.
        case incorrectClosureType
    }

}
