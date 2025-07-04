import ProjectDescription

let project = Project(
    name: "Itadaki",
    organizationName: "Aethercode Labs",
    targets: [
        .target(
            name: "Itadaki",
            destinations: .iOS,
            product: .app,
            bundleId: "com.aethercodelabs.itadaki",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/Itadaki/**"],
            resources: ["Resources/**"],
            dependencies: [
                .target(name: "ItadakiUI"),
                .target(name: "ItadakiData"),
                .target(name: "ItadakiKit")
            ],
            settings: .settings(
                base: [
                    "CODE_SIGN_STYLE": "Automatic",
                    "DEVELOPMENT_TEAM": "7YF7AKC3MY"
                ]
            )
        ),
        .target(
            name: "ItadakiUI",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.aethercodelabs.itadaki.ui",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/ItadakiUI/**"],
            dependencies: [
                .target(name: "ItadakiKit")
            ]
        ),
        .target(
            name: "ItadakiData",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.aethercodelabs.itadaki.data",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/ItadakiData/**"],
            dependencies: [
                .external(name: "GRDB"),
                .target(name: "ItadakiKit")
            ]
        ),
        .target(
            name: "ItadakiKit",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.aethercodelabs.itadaki.kit",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/ItadakiKit/**"]
        )
    ]
)
