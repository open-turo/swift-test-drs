// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "TestDRS",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TestDRS",
            targets: ["TestDRS"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.2"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", .upToNextMajor(from: "0.4.0")),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", .upToNextMajor(from: "1.1.2"))
    ],
    targets: [
        // TestDRS macros target
        .macro(
            name: "TestDRSMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        // Library that exposes TestDRS macros as part of its API
        .target(
            name: "TestDRS",
            dependencies: [
                "TestDRSMacros",
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
            ],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),

        // Unit tests for TestDRS
        .testTarget(
            name: "TestDRSTests",
            dependencies: [
                .product(name: "MacroTesting", package: "swift-macro-testing"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                "TestDRS",
                "TestDRSMacros",
            ],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),
    ]
)
