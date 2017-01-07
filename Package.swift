import PackageDescription

let package = Package(
    name: "vapor-example",
    targets: [
        Target(name: "App", dependencies: ["Library"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 3),
        .Package(url: "https://github.com/vapor/mysql-provider", majorVersion: 1, minor: 1),
        .Package(url: "https://github.com/vapor/redis-provider", majorVersion: 1, minor: 0),
        .Package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver-Vapor.git", majorVersion: 1),
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)

