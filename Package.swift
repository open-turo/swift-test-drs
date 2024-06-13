// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "TestDRS",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "TestDRS",
            targets: ["Mocking", "Expectations"]
        ),
        .library(
            name: "TestDRSMocking",
            targets: ["Mocking"]
        ),
        .executable(
            name: "ExampleClient",
            targets: ["ExampleClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.2"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", .upToNextMajor(from: "0.4.0")),
    ],
    targets: [
        // Macros

        .macro(
            name: "MockingMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        .macro(
            name: "ExpectationMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        // Modules

        .target(
            name: "TestDRSCore",
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),

        .target(
            name: "Mocking",
            dependencies: [
                "TestDRSCore",
                "MockingMacros",
            ],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),

        .target(
            name: "Expectations",
            dependencies: [
                "TestDRSCore",
                "ExpectationMacros",
            ],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),

        // Macro Tests

        .testTarget(
            name: "MockingMacrosTests",
            dependencies: [
                .product(name: "MacroTesting", package: "swift-macro-testing"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                "TestDRSCore",
                "MockingMacros",
            ],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),

        .testTarget(
            name: "ExpectationMacrosTests",
            dependencies: [
                .product(name: "MacroTesting", package: "swift-macro-testing"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                "TestDRSCore",
                "ExpectationMacros",
            ],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),

        // Module Tests

        .testTarget(
            name: "TestDRSCoreTests",
            dependencies: [
                "TestDRSCore",
            ],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),

        .testTarget(
            name: "MockingTests",
            dependencies: [
                "TestDRSCore",
                "Mocking",
                "Expectations",
            ],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),

        .testTarget(
            name: "ExpectationsTests",
            dependencies: [
                "TestDRSCore",
                "Expectations",
            ],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),

        // An example client used to try out TestDRS
        // TODO: Move this out of TestDRS package

        .executableTarget(name: "ExampleClient", dependencies: ["TestDRSCore", "Mocking"]),

        .testTarget(
            name: "ExampleClientTests",
            dependencies: [
                "ExampleClient",
                "TestDRSCore",
                "Mocking",
                "Expectations",
            ],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),
    ]
)
