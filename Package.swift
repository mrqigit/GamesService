// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "GamesService",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        // Vapor ORM (queries, models, and relations) for NoSQL and SQL databases
        .package(url: "https://github.com/vapor/fluent.git", from: "4.12.0"),
        // 🔑 JSON Web Token (JWT) signing and verification (HMAC, ECDSA, EdDSA, RSA, PSS) with support for JWS and JWK
        .package(url: "https://github.com/vapor/jwt.git", from: "4.0.0"),
        // 🐘 PostgreSQL driver for Fluent.
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.10.1"),
    ],
    targets: [
        .executableTarget(
            name: "GamesService",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "JWT", package: "jwt"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "GamesServiceTests",
            dependencies: [
                .target(name: "GamesService"),
                .product(name: "VaporTesting", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        )
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }
