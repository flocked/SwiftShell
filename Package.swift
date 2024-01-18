// swift-tools-version:5.5
import PackageDescription

let package = Package(
	name: "SwiftShell",
    platforms: [.macOS("10.15.1"), .iOS(.v14), .macCatalyst(.v14), .tvOS(.v14), .watchOS(.v6)],
	products: [
		.library(
			name: "SwiftShell",
			targets: ["SwiftShell"])
	],
    dependencies: [
        .package(url: "https://github.com/flocked/FZSwiftUtils.git", branch: "main"),
    ],
	targets: [
		.target(
			name: "SwiftShell",
            dependencies: ["FZSwiftUtils"],
			swiftSettings: [
				.define("DEBUG", .when(configuration: .debug)),
			]),
		.testTarget(
			name: "SwiftShellTests",
			dependencies: ["SwiftShell"]),
		.testTarget(
			name: "StreamTests",
			dependencies: ["SwiftShell"]),
		.testTarget(
			name: "GeneralTests",
			dependencies: ["SwiftShell"]),
	],
	swiftLanguageVersions: [.v4_2, .v5]
)
