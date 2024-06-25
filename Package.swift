// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "TestDRS",
    platforms: [.macOS(.v10_15), .iOS(.v16), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "TestDRS",
            targets: ["TestDRS"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", branch: "release/6.0"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", .upToNextMajor(from: "0.4.0")),
        .package(url: "https://github.com/apple/swift-testing.git", from: "0.10.0"),
    ],
    targets: [
        .macro(
            name: "TestDRSMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        .target(
            name: "TestDRS",
            dependencies: [
                "TestDRSMacros",
            ],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),

        .testTarget(
            name: "TestDRSTests",
            dependencies: [
                .product(name: "Testing", package: "swift-testing"),
                "TestDRS",
                "TestDRSMacros",
            ],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),

        .testTarget(
            name: "TestDRSMacrosTests",
            dependencies: [
                .product(name: "MacroTesting", package: "swift-macro-testing"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                "TestDRSMacros",
            ],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),
    ]
)
