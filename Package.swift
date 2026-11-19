// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LosPrimosMusic",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "LosPrimosMusicCore",
            targets: ["LosPrimosMusicCore"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LosPrimosMusicCore",
            dependencies: [],
            path: ".",
            exclude: [
                "Resources",
                "Docs",
                "App/Info.plist"
            ],
            sources: [
                "App/LosPrimosMusicApp.swift",
                "Core",
                "Models",
                "DesignSystem",
                "Views"
            ]
        )
    ]
)
