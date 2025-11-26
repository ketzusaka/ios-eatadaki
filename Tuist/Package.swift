// swift-tools-version: 6.2
import PackageDescription

#if TUIST
import struct ProjectDescription.PackageSettings

let packageSettings = PackageSettings(
    productTypes: [
        "GRDB": .framework
    ]
)
#endif

let package = Package(
    name: "Eatadaki",
    platforms: [
        .iOS(.v26)
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.0.0")
    ]
)

