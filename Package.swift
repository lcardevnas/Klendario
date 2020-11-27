// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Klendario",
    platforms: [
        .iOS(.v9),
    ],
    products: [
        .library(
            name: "Klendario",
            targets: ["Klendario"]),
    ],
    dependencies: [
        // no dependencies
    ],
    targets: [
        .target(
            name: "Klendario",
            dependencies: []),
    ]
)
