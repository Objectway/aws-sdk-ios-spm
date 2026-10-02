// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Custom AWS iOS SDK version
let latestVersion = "2.41.0-custom.1"

let hostingUrl = "https://github.com/Objectway/aws-sdk-ios-spm/releases/download/v\(latestVersion)/"

enum BuildMode {
    case remote
    case localWithDictionary
    case localWithFilesystem
}

let localPath = "XCF"

// The published package uses the XCFrameworks from the GitHub Release.
let buildMode = BuildMode.remote

// Checksums for the custom XCFramework ZIP artifacts.
//
// These checksums correspond to the ZIP files generated from the
// custom XCFrameworks built from the forked aws-sdk-ios repository.
let frameworksToChecksum = [
    "AWSCore": "48a0211d703d4074ad26e216dcdc4fddcd8171ce31d6250c9c77848da00b0e47",
    "AWSCognitoIdentityProviderASF": "31b3ac76f9b294cb54d6ea869d836152f11ba9b11e44aad29b76eed2939546b5",
    "AWSCognitoAuth": "e62721275ae8ebb8e046674105688a6e43da7d1eabf579b973061c2f2c337e63"
]

extension Target.Dependency {
    // Framework dependencies present in the SDK
    static let awsCore: Self = .target(name: "AWSCore")
    static let awsCognitoIdentityProviderASF: Self = .target(name: "AWSCognitoIdentityProviderASF")
}

let depdenencyMap: [String: [Target.Dependency]] = [
    "AWSCore": [],
    "AWSCognitoIdentityProviderASF": [.awsCore],
    "AWSCognitoAuth": [.awsCore, .awsCognitoIdentityProviderASF]
]

var frameworksOnFilesystem: [String] {
    let fileManager = FileManager.default
    let rootURL = URL(fileURLWithPath: #file).deletingLastPathComponent()
    let xcfURL = rootURL.appendingPathComponent(localPath)
    let paths = (try? fileManager.contentsOfDirectory(atPath: xcfURL.path)) ?? []
    let frameworks = paths
        .filter { $0.hasSuffix(".xcframework") }
        .map { xcfURL.appendingPathComponent($0) }
        .map { $0.deletingPathExtension().lastPathComponent }
        .sorted()
    return frameworks
}

var frameworksFromDictionary: [String] {
    frameworksToChecksum.map { $0.key }.sorted()
}

let frameworks = buildMode == .localWithFilesystem ? frameworksOnFilesystem : frameworksFromDictionary

func createProducts() -> [Product] {
    let products: [Product]
    if buildMode != .remote {
        products = frameworks.map { Product.library(name: $0, targets: [$0]) }
    } else {
        products = frameworks.map { framework -> Product in
            if depdenencyMap[framework]!.isEmpty {
                return Product.library(name: framework, targets: [framework])
            }

            // If framework has dependencies, create a `<framework>-Target`
            // library that is used to link framework target with its dependencies.
            return Product.library(name: framework, targets: ["\(framework)-Target"])
        }
    }
    return products
}

func createTarget(framework: String, checksum: String = "") -> Target {
    buildMode != .remote
        ? Target.binaryTarget(
            name: framework,
            path: "\(localPath)/\(framework).xcframework"
        )
        : Target.binaryTarget(
            name: framework,
            url: "\(hostingUrl)\(framework)-\(latestVersion).zip",
            checksum: checksum
        )
}

func createTargets() -> [Target] {
    let targets: [Target]

    if buildMode != .remote {
        targets = frameworks.map {
            createTarget(framework: $0)
        }
    } else {
        targets = frameworksToChecksum.flatMap { framework, checksum -> [Target] in
            var targets = [createTarget(
                framework: framework,
                checksum: checksum
            )]

            // If the framework has dependencies, create an additional target
            // that links the framework and its dependencies.
            if var dependencies = depdenencyMap[framework], !dependencies.isEmpty {
                dependencies.append(.target(name: framework))

                targets.append(
                    .target(
                        name: "\(framework)-Target",
                        dependencies: dependencies,
                        path: "DependantTargets/\(framework)-Target"
                    )
                )
            }

            return targets
        }
    }

    return targets
}

let products = createProducts()
let targets = createTargets()

let package = Package(
    name: "AWSiOSSDKV2",
    platforms: [
        .iOS(.v12)
    ],
    products: products,
    targets: targets
)
