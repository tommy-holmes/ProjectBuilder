struct Prompt {
    let content: String
    
    init(_ content: String) {
        self.content = content
    }
}

extension Prompt: CustomStringConvertible {
    var description: String { content }
}

extension Prompt: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self.content = value
    }
}

extension Prompt {
    static let xcodeSystemPrompt: Self = """
        Update Package.swift with any module's dependencies following specified hierarchy without creating cycles. Implement initial files as per Swift best practices, focusing on .swift files in a JSON format. Do not touch any auxiliary files like `.xcworkspace` or `.xcodeproj`. 
        
        Adhere to the hierarchy: Core modules -> Dependencies (Clients) -> Features -> Targets (AppFeature) while managing dependencies.
        
        # Steps
        
        1. Receive the structure and specifications for the Xcode project.
        2. Follow the path structure of `Packages/Sources/{PackageName}` for source modules and `Packages/Tests/{PackageNameTests}` for test modules.
        3. Write boilerplate code for each initial file in specified packages.
        4. Update `Package.swift` to reflect the dependency chain while avoiding cycles, aligning with the hierarchy: Core modules -> Dependencies -> Features -> Targets.
        5. Ensure best practices: maintain DRY principles, use the Swift Observation framework, minimize state wrapping, and model non-local state in `@Observable ViewModel`.
        
        # Output Format
        
        Provide your response in pure JSON. Use the path of each file as the key and the corresponding code as the value. Ensure JSON is properly formatted, without wrapping in code blocks.
        
        # Examples
        
        {
        "Packages/Sources/FeatureA/FeatureANavigationStack.swift": "import SwiftUI\n...\nstruct FeatureANavigationStack: View { ... }",
        "Packages/Sources/FeatureB/MyObservableObject.swift": "import Observation\n...\n@Observable\nfinal class MyObservableObject { ... }",
        "Packages/Tests/FeatureBTests/ViewModelTests.swift": "import Testing\n@testable import FeatureB\n...\n@Suite(\"ViewModelTests\")\nstruct ViewModelTests { \n@Test(\"Some test\")\nfunc someTest: async throws () -> Void { ... }\n ... }",
        }
        
        # Notes
        
        - Handle edge cases where complex views or objects may require different patterns.
        - Ensure paths are accurate and code adheres strictly to Swift syntax and conventions.
        - Consider real-world complexity, and adapt code to fit realistic requirements.
        - Write any unit tests in test modules with the new Swift Testing framework.
        - Manage dependencies in `Package.swift` focusing on the specified hierarchy while avoiding dependency cycles.
        
        When editing the package.swift, use the following example:
        
        ```
        // swift-tools-version: 6.1
        
        import PackageDescription
        
        enum Dependencies {
        static var common: [Target.Dependency] {
        [
            "SharedViews",
            "SharedModels",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        ]
        }
        }
        
        let package = Package(
        name: "Main",
        platforms: [.iOS(.v18)],
        products: [
        .singleTargetLibrary("AppFeature"),
        ],
        dependencies: [
        .package(url: "https://github.com/krzysztofzablocki/Inject.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "11.0.0")),
        ],
        targets: [
        .target(
            name: "AppFeature",
            dependencies: Dependencies.common + [
                "AuthenticationFeature",
                "ExploreFeature",
                "ExchangeFeature",
            ]
        ),
        .target(
            name: "AuthenticationFeature",
            dependencies: Dependencies.common + [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
            ]
        ),
        .target(
            name: "OrderHistoryFeature",
            dependencies: Dependencies.common + [
                "ExchangeFeature",
                "Networking",
            ]
        ),
        .target(
            name: "ExchangeFeature",
            dependencies: Dependencies.common + [
                "Networking",
                "SupportFeature",
            ]
        ),
        .target(
            name: "AccountFeature",
            dependencies: [
                "SupportFeature",
                "SharedViews",
            ]
        ),
        .target(
            name: "OnboardingFeature",
            dependencies: [
                "SharedViews",
            ]
        ),
        .target(
            name: "Networking",
            dependencies: [
                "SharedModels",
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "SharedViews",
            dependencies: [
                "SharedModels",
                "Inject",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            resources: [
                .process("Fonts"),
            ]
        ),
        .target(
            name: "SharedModels"
        ),
        .testTarget(
            name: "AppFeatureTests",
            dependencies: ["AppFeature"]
        ),
        .testTarget(
            name: "SharedModelsTests",
            dependencies: [
                "SharedModels",
            ]
        ),
        .testTarget(
            name: "NetworkingTests",
            dependencies: [
                "Networking",
            ]
        ),
        ]
        )
        
        extension Product {
        static func singleTargetLibrary(_ name: String) -> Product {
        .library(name: name, targets: [name])
        }
        }
        ```
        """
    static func xcodePrompt(for appStructure: String, supportingInstructions: String) -> Self {
        Prompt("""
        Write starting files for the Xcode project with the following structure: 
        ```
        \(appStructure)
        ```
        # Instructions
        \(supportingInstructions)
        """)
    }
}
