// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "HTTPRequestClient",
  platforms: [
    .macOS(.v13),
    .iOS(.v16),
    .watchOS(.v8),
    .tvOS(.v16),
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "HTTPRequestClient",
      targets: ["HTTPRequestClient"]
    )
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(url: "https://github.com/4rays/http-request-builder", from: "1.2.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.4.0"),
    .package(url: "https://github.com/kean/Pulse.git", from: "5.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "HTTPRequestClient",
      dependencies: [
        .product(name: "HTTPRequestBuilder", package: "http-request-builder"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        .product(name: "Pulse", package: "Pulse"),
      ]
    ),
    .testTarget(
      name: "HTTPRequestClientTests",
      dependencies: ["HTTPRequestClient"]
    ),
  ],
  swiftLanguageModes: [.v6]
)
