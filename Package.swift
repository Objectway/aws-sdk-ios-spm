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
    "AWSAPIGateway": "9f5bbaec960f2159d63d79e5a193f2b50e6a35507c34026e5cee1cc445ecca75",
    "AWSAppleSignIn": "f54a6c1453a70508c33a335aad1bd6cc83d0bb1a35cdb958fd5c4a2e03c74036",
    "AWSAuthCore": "8c8406c27bd9890b3edfd0b5606051d2245e53567254d31d41b935ac44911bed",
    "AWSAuthUI": "42c0a20922de96029704f92aac7131e7d7a6b9afcbf6a1e6323ed558d5a8aec6",
    "AWSAutoScaling": "586168af28a053b330949df465f97f47cea7abaf7c817778c2a9ebb444636d83",
    "AWSChimeSDKIdentity": "31afb899ff14afbf8b6bf764e65a3371ab4a251dbc24c676d77d91c7caf55e95",
    "AWSChimeSDKMessaging": "5cf12f8f84d3f258d7a28f7af39d9faf2785acaf1d8f7cbed22c861cd9b244b2",
    "AWSCloudWatch": "911a5583f8e537e986f31a5266038f74a63105c758e64522e20f6976a7f45480",
    "AWSCognitoAuth": "e62721275ae8ebb8e046674105688a6e43da7d1eabf579b973061c2f2c337e63",
    "AWSCognitoIdentityProvider": "fed5c8cf01dc6d86155d6c15ad3ce658edad40577c42cdd657d3ad246770c3f1",
    "AWSCognitoIdentityProviderASF": "31b3ac76f9b294cb54d6ea869d836152f11ba9b11e44aad29b76eed2939546b5",
    "AWSComprehend": "db35cd846c503bbbcf3fa7839c180a6fb8a956eedde2b085451b2db66966e990",
    "AWSConnect": "f081b9246d41e9f6d3b9b11ac71b4117fc47095a2506369d79d33082cd13c0f0",
    "AWSConnectParticipant": "db35c6ee15b9e5c64a4de5ea21f0f0561ee5f65491672770d2109c83a10d199e",
    "AWSCore": "48a0211d703d4074ad26e216dcdc4fddcd8171ce31d6250c9c77848da00b0e47",
    "AWSDynamoDB": "5b4f8249727698ccb18d96a1ee3e1325f14714bab3b769bcf55e38d009ff340b",
    "AWSEC2": "e5dc3870855a083490f69bc3360105857e0913a5568fc6fa8f5b79ebc1007b4c",
    "AWSElasticLoadBalancing": "80f2d485dbbf2a5d2f7a3ef4024f2e8bf46a241855d121c34c4dc25855060bc5",
    "AWSFacebookSignIn": "aa211aff33139982e04b4537d327433a7894e24c415ed598df8f34bc44760a4a",
    "AWSGoogleSignIn": "4ced7d5ed9692b773877e58e8c7eb2be39d3a6e73d7c2953af9dd4a3385d0318",
    "AWSIoT": "92e970ef2dd7539416ec994019a879d3ce96d655f2a41d4d087e2fd2d73e5731",
    "AWSKinesis": "553bc4f3c6547612acd098fd76ee0398d3f4793a587acbb4bb1e7c2b18f6585d",
    "AWSKinesisVideo": "b24e39347ebe1fca460586f917f4ecab435982cc5a8b93e2b8b8ac5938936e9d",
    "AWSKinesisVideoArchivedMedia": "d04b763e659b9dcf54d8707f69843ea08339561998f8a5bb768d34f47bd81c8c",
    "AWSKinesisVideoSignaling": "fe3ffd62d9e1019606b36c602dcc7f4bb0cedd40566b0954abd677a59e635afc",
    "AWSKinesisVideoWebRTCStorage": "9506065098943dfbecadea9f49017302cdd3a636b3eb7f83cbe870b756c2a609",
    "AWSKMS": "0645c84feea9262187b504edf798b0d6674cd54e126e36fb83e39218f220de5b",
    "AWSLambda": "c6f9b1cf397f08fcd1097d74fa2d4951aec971a54b7acec82daa169602c59468",
    "AWSLex": "cf7a6599c9d87127d5cc946021c9a970d8536a11c0d4464d7c72d3327ab55613",
    "AWSLocationXCF": "61c8b8a0ea04e3b01de9fc0ffa84602d41b6f9e90a38e6bb732175761e206294",
    "AWSLogs": "5a17f090b82e43a9526de50c7300a078fa213c033edb22a3f82f67553a649526",
    "AWSMachineLearning": "6b9070686fb01226fedb8cd961601884960e51898b9922c6b93bc686b265b87c",
    "AWSMobileClientXCF": "ef3f65d7b833d2f259f8c70816fe1f151566a2336126883eeb8dfd10d8bc14b5",
    "AWSPinpoint": "df17e5c7924e35431e745e9a132f3a297b9f579ea17c278cd21cc808fd1c96d5",
    "AWSPolly": "abf45a9a60bfda70e2ef8edb7a3cfc20da6627897253dbbee1bf21de95ebae3e",
    "AWSRekognition": "180b9315d3aa683007e0e05eb133b5fa0858d662d327972f8be27a2feaf2191a",
    "AWSS3": "0061dd6c2340b4c1a9c310ea18731ac714bf3f89722a2c531ee0992572b269ae",
    "AWSSageMakerRuntime": "7d146300dff63f62144c9fbd6b5e701b2408fc8d31579d1d3f9dcd77699514bd",
    "AWSSES": "46fe14d0f5e98a94eb368b24d27476ed38343c7e7cf71b6d532237ff7337efd5",
    "AWSSimpleDB": "f0c1c0b2319254f7eeb7d208b2fbdb1faa54e24ba19ea39dea228f93de1c9f07",
    "AWSSNS": "12a7a1926b0a2d223769bc7274307d57f982b0c3213ee977e8bb509cdf0b3207",
    "AWSSQS": "45448ee261397db0c47ad9b90853b2e29d24188f5273c86353501dc49a3c3f0d",
    "AWSTextract": "ef5afcd76edd43235d81740df4adb6e6db78dd9822304933cbdde31188a14836",
    "AWSTranscribe": "1038ea26c062d4ab66bcd33ea49d2ab5dedfdc963964c809509ffd88cb65a4cc",
    "AWSTranscribeStreaming": "cc0ecad1a5527dbb68b58f24075c1b33ffecf8dec1213736e34349abfa3690fb",
    "AWSTranslate": "479dc7f91657bad498564b5791f298f985f6f9e23aa81ce155f7a7e6e5460414",
    "AWSUserPoolsSignIn": "9ff4179327b9cbf4de85d6c45b92a3250371ab98528f6a0edcce42bad3511777"
]

extension Target.Dependency {
    // Framework dependencies present in the SDK
    static let awsCore: Self = .target(name: "AWSCore")
    static let awsAuthCore: Self = .target(name: "AWSAuthCore")
    static let awsCognitoIdentityProviderASF: Self = .target(name: "AWSCognitoIdentityProviderASF")
    static let awsCognitoIdentityProvider: Self = .target(name: "AWSCognitoIdentityProvider")
}

let depdenencyMap: [String: [Target.Dependency]] = [
    "AWSAPIGateway": [.awsCore],
    "AWSAppleSignIn": [.awsCore, .awsAuthCore],
    "AWSAuthCore": [.awsCore],
    "AWSAuthUI": [.awsCore, .awsAuthCore],
    "AWSAutoScaling": [.awsCore],
    "AWSChimeSDKIdentity": [.awsCore],
    "AWSChimeSDKMessaging": [.awsCore],
    "AWSCloudWatch": [.awsCore],
    "AWSCognitoAuth": [.awsCore, .awsCognitoIdentityProviderASF],
    "AWSCognitoIdentityProvider": [.awsCore, .awsCognitoIdentityProviderASF],
    "AWSCognitoIdentityProviderASF": [.awsCore],
    "AWSComprehend": [.awsCore],
    "AWSConnect": [.awsCore],
    "AWSConnectParticipant": [.awsCore],
    "AWSCore": [],
    "AWSDynamoDB": [.awsCore],
    "AWSEC2": [.awsCore],
    "AWSElasticLoadBalancing": [.awsCore],
    "AWSFacebookSignIn": [.awsCore, .awsAuthCore],
    "AWSGoogleSignIn": [.awsCore, .awsAuthCore],
    "AWSIoT": [.awsCore],
    "AWSKMS": [.awsCore],
    "AWSKinesis": [.awsCore],
    "AWSKinesisVideo": [.awsCore],
    "AWSKinesisVideoArchivedMedia": [.awsCore],
    "AWSKinesisVideoSignaling": [.awsCore],
    "AWSKinesisVideoWebRTCStorage": [.awsCore],
    "AWSLambda": [.awsCore],
    "AWSLex": [.awsCore],
    "AWSLocationXCF": [.awsCore],
    "AWSLogs": [.awsCore],
    "AWSMachineLearning": [.awsCore],
    "AWSMobileClientXCF": [.awsAuthCore, .awsCognitoIdentityProvider],
    "AWSPinpoint": [.awsCore],
    "AWSPolly": [.awsCore],
    "AWSRekognition": [.awsCore],
    "AWSS3": [.awsCore],
    "AWSSES": [.awsCore],
    "AWSSNS": [.awsCore],
    "AWSSQS": [.awsCore],
    "AWSSageMakerRuntime": [.awsCore],
    "AWSSimpleDB": [.awsCore],
    "AWSTextract": [.awsCore],
    "AWSTranscribe": [.awsCore],
    "AWSTranscribeStreaming": [.awsCore],
    "AWSTranslate": [.awsCore],
    "AWSUserPoolsSignIn": [.awsCognitoIdentityProvider, .awsAuthCore, .awsCore]
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
        .iOS(.v9)
    ],
    products: products,
    targets: targets
)
