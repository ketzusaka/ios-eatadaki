import ProjectDescription

// MARK: - Packages

let packages: [Package] = [
    .package(
        url: "https://github.com/groue/GRDB.swift.git",
        .upToNextMajor(from: "6.0.0")
    )
]

// MARK: - Project

let project = Project(
    name: "Eatadaki",
    organizationName: "Aethercode Labs",
    packages: packages,
    settings: .settings(
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release")
        ]
    ),
    targets: [

        // MARK: - App
        
        .target(
            name: "Eatadaki",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.aethercodelabs.eatadaki",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [:]
                ]
            ),
            sources: ["Eatadaki/Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .target(name: "EatadakiUI"),
                .target(name: "EatadakiData"),
                .target(name: "EatadakiKit"),
                .target(name: "EatadakiSpotsKit"),
                .target(name: "EatadakiLocationKit"),
                .target(name: "Pour"),
                .package(product: "GRDB")
            ],
            settings: .settings(
                configurations: [
                    .debug(
                        name: "Debug",
                        settings: [
                            "PRODUCT_BUNDLE_IDENTIFIER": "com.aethercodelabs.eatadaki.dev"
                        ]
                    ),
                    .release(name: "Release")
                ]
            )
        ),

        // MARK: - Frameworks
        
        .target(
            name: "EatadakiUI",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.aethercodelabs.eatadaki.ui",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .default,
            sources: ["EatadakiUI/Sources/**"],
            dependencies: [
                .target(name: "EatadakiKit"),
                .target(name: "EatadakiData"),
                .target(name: "Pour")
            ]
        ),

        .target(
            name: "EatadakiData",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.aethercodelabs.eatadaki.data",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .default,
            sources: ["EatadakiData/Sources/**"],
            dependencies: [
                .package(product: "GRDB"),
                .target(name: "EatadakiKit"),
                .target(name: "Pour")
            ]
        ),

        .target(
            name: "EatadakiKit",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.aethercodelabs.eatadaki.kit",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .default,
            sources: ["EatadakiKit/Sources/**"],
            dependencies: [
                .target(name: "Pour")
            ]
        ),

        .target(
            name: "EatadakiLocationKit",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.aethercodelabs.eatadaki.locationkit",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .default,
            sources: ["EatadakiLocationKit/Sources/**"],
            dependencies: [
                .target(name: "EatadakiData"),
                .target(name: "EatadakiKit"),
                .target(name: "Pour")
            ]
        ),

        .target(
            name: "EatadakiSpotsKit",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.aethercodelabs.eatadaki.spotskit",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .default,
            sources: ["EatadakiSpotsKit/Sources/**"],
            dependencies: [
                .target(name: "EatadakiData"),
                .target(name: "EatadakiKit"),
                .target(name: "EatadakiLocationKit")
            ]
        ),

        .target(
            name: "Pour",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.aethercodelabs.eatadaki.pour",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .default,
            sources: ["Pour/Sources/**"]
        ),

        // MARK: - Tests
        .target(
            name: "EatadakiTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "com.aethercodelabs.eatadaki.tests",
            deploymentTargets: .iOS("26.0"),
            sources: ["Eatadaki/Tests/**"],
            dependencies: [.target(name: "Eatadaki")]
        ),

        .target(
            name: "EatadakiUITests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "com.aethercodelabs.eatadaki.ui.tests",
            deploymentTargets: .iOS("26.0"),
            sources: ["EatadakiUI/Tests/**"],
            dependencies: [.target(name: "EatadakiUI")]
        ),

        .target(
            name: "EatadakiDataTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "com.aethercodelabs.eatadaki.data.tests",
            deploymentTargets: .iOS("26.0"),
            sources: ["EatadakiData/Tests/**"],
            dependencies: [
                .target(name: "EatadakiData"),
                .package(product: "GRDB")
            ]
        ),

        .target(
            name: "EatadakiKitTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "com.aethercodelabs.eatadaki.kit.tests",
            deploymentTargets: .iOS("26.0"),
            sources: ["EatadakiKit/Tests/**"],
            dependencies: [.target(name: "EatadakiKit")]
        ),

        .target(
            name: "PourTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "com.aethercodelabs.eatadaki.pour.tests",
            deploymentTargets: .iOS("26.0"),
            sources: ["Pour/Tests/**"],
            dependencies: [.target(name: "Pour")]
        ),

        .target(
            name: "EatadakiAppUITests",
            destinations: [.iPhone],
            product: .uiTests,
            bundleId: "com.aethercodelabs.eatadaki.ui-tests",
            deploymentTargets: .iOS("26.0"),
            sources: ["Eatadaki/Tests/UITests/**"],
            dependencies: [.target(name: "Eatadaki")]
        )
    ]
)
