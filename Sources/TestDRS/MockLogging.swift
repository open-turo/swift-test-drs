//
// Created on 8/21/25.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// Enables TestDRS mock logging for the duration of the given operation.
///
/// - Parameters:
///   - identifier: The emoji identifier to prefix log messages. Defaults to "🏎️".
///   - testName: The test name to include in log messages. Defaults to the calling function name.
///   - operation: The operation to run with logging enabled.
/// - Returns: The result of the operation.
@discardableResult
public func withMockLogging<R>(identifier: String = "🏎️", testName: String = #function, operation: () throws -> R) rethrows -> R {
    try TestDRSMockLogger.$current.withValue(TestDRSMockLogger(identifier: identifier, testName: testName)) {
        try operation()
    }
}

/// Enables TestDRS mock logging for the duration of the given async operation.
///
/// - Parameters:
///   - identifier: The emoji identifier to prefix log messages. Defaults to "🏎️".
///   - testName: The test name to include in log messages. Defaults to the calling function name.
///   - operation: The async operation to run with logging enabled.
/// - Returns: The result of the operation.
@discardableResult
public func withMockLogging<R>(identifier: String = "🏎️", testName: String = #function, operation: () async throws -> R) async rethrows -> R {
    try await TestDRSMockLogger.$current.withValue(TestDRSMockLogger(identifier: identifier, testName: testName)) {
        try await operation()
    }
}

func withMockLogging<R>(identifier: String = "🏎️", testName: String = #function, print: (@Sendable (String) -> Void)? = nil, operation: () throws -> R) rethrows -> R {
    try TestDRSMockLogger.$current.withValue(
        TestDRSMockLogger(
            identifier: identifier,
            testName: testName,
            print: print
        )
    ) {
        try operation()
    }
}

/// Context for mock logging that tracks component instances and provides numbered identifiers
public final class TestDRSMockLogger: Sendable {

    private let continuation: AsyncStream<Event>.Continuation
    private let print: @Sendable (String) -> Void
    private let testNameSuffix: String?
    private let identifier: String

    init(identifier: String = "🏎️", testName: String? = nil, print: (@Sendable (String) -> Void)? = nil) {
        let (stream, continuation) = AsyncStream<Event>.makeStream()
        self.continuation = continuation
        testNameSuffix = testName.map { " in \($0)" }
        self.identifier = identifier
        self.print = print ?? { string in Swift.print(string) }
        Task {
            await self.processEvents(stream)
        }
    }

    deinit {
        continuation.finish()
    }

    /// Register a mock component with the logger
    func register<Mock, Component: AnyObject>(
        component: Component,
        mockType: Mock.Type
    ) {
        let componentInfo = ComponentInfo(component: component, mockType: mockType)
        continuation.yield(.register(componentInfo: componentInfo))
    }

    /// Log a message from a mock component
    func log<Mock, Component: AnyObject>(
        component: Component,
        mockType: Mock.Type,
        message: String
    ) {
        let componentInfo = ComponentInfo(component: component, mockType: mockType)
        continuation.yield(.log(componentInfo: componentInfo, message: message))
    }

    private func processEvents(_ stream: AsyncStream<Event>) async {
        var context = Context()

        for await event in stream {
            switch event {
            case .register(componentInfo: let componentInfo):
                let componentIdentifier = context.logIdentifier(for: componentInfo)
                print("\(identifier) Registered \(componentIdentifier)\(testNameSuffix ?? "")")
            case .log(componentInfo: let componentInfo, message: let message):
                let componentIdentifier = context.logIdentifier(for: componentInfo)
                print("\(identifier) \(componentIdentifier) \(message)\(testNameSuffix ?? "")")
            }
        }
    }

}

extension TestDRSMockLogger {

    private struct ComponentInfo {
        let id: ObjectIdentifier
        let componentType: String
        let mockType: String

        init<Mock, Component: AnyObject>(
            component: Component,
            mockType: Mock.Type
        ) {
            id = ObjectIdentifier(component)
            componentType = String(describing: Component.self)
            self.mockType = String(describing: Mock.self)
        }
    }

    private enum Event {
        case register(componentInfo: ComponentInfo)
        case log(componentInfo: ComponentInfo, message: String)
    }

    private struct Context {
        var componentRegistry: [ObjectIdentifier: String] = [:] // Component ID -> identifier
        var typeCounts: [String: Int] = [:] // Component type name -> count

        mutating func logIdentifier(for componentInfo: ComponentInfo) -> String {
            if let logIdentifier = componentRegistry[componentInfo.id] {
                return logIdentifier
            }

            let fullType = "\(componentInfo.mockType).\(componentInfo.componentType)"

            let count = typeCounts[fullType, default: 0] + 1
            typeCounts[fullType] = count

            let logIdentifier = count == 1 ? fullType : "\(componentInfo.mockType)\(numberEmoji(for: count)).\(componentInfo.componentType)"
            componentRegistry[componentInfo.id] = logIdentifier

            return logIdentifier
        }

        private func numberEmoji(for number: Int) -> String {
            switch number {
            case 1: return "1️⃣"
            case 2: return "2️⃣"
            case 3: return "3️⃣"
            case 4: return "4️⃣"
            case 5: return "5️⃣"
            case 6: return "6️⃣"
            case 7: return "7️⃣"
            case 8: return "8️⃣"
            case 9: return "9️⃣"
            case 10: return "🔟"
            default: return "\(number)️⃣"
            }
        }
    }

}

extension TestDRSMockLogger {

    @TaskLocal static var current: TestDRSMockLogger?

}
