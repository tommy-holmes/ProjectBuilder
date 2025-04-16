import Foundation

/// Generates the package directories, modules, and Package.swift file.
struct PackageGenerator: ComponentGenerator {
    let fileManager: FileManager
    
    func generate(with context: inout GenerationContext) throws {
//        guard let projectPath = context.projectPath else { throw GenerationError.missingProjectDirectory }
        guard let packagesPath = context.packagesPath else { throw GenerationError.missingPackagesDirectory }
        
        // Create the "Sources" and "Tests" directories within Packages.
        let pkgSourcesPath = (packagesPath as NSString).appendingPathComponent("Sources")
        let pkgTestsPath = (packagesPath as NSString).appendingPathComponent("Tests")
        try fileManager.createDirectory(atPath: pkgSourcesPath, withIntermediateDirectories: true)
        try fileManager.createDirectory(atPath: pkgTestsPath, withIntermediateDirectories: true)
        
        print("✅ Package directories created at: \(pkgSourcesPath) and \(pkgTestsPath)")
        
        // Generate modules as defined by the configuration.
        for module in context.configuration.modules {
            try generateModule(module: module, in: packagesPath)
        }
        
        // Write Package.swift with all module definitions.
        try generatePackageSwift(in: packagesPath, configuration: context.configuration)
        print("✅ Package.swift generated")
    }
    
    private func generateModule(module: Module, in packagesPath: String) throws {
        let pkgSourcesPath = (packagesPath as NSString).appendingPathComponent("Sources")
        let modulePath = (pkgSourcesPath as NSString).appendingPathComponent(module.name)
        try fileManager.createDirectory(atPath: modulePath, withIntermediateDirectories: true)
        
        let viewNamePrefix = module.name.replacing("Feature", with: "")
        
        // Write the main module file.
        let moduleFilePath = (modulePath as NSString).appendingPathComponent("\(viewNamePrefix)View.swift")
        let moduleContents = """
        import SwiftUI
        
        public struct \(viewNamePrefix)View: View {
            public init() { }
            
            public var body: some View {
                Text("Hello, World!")
            }
        }
        """
        try moduleContents.write(toFile: moduleFilePath, atomically: true, encoding: .utf8)
        print("   \(module.name) module generated")
        
        // Generate tests if required.
        if module.includeTests {
            let pkgTestsPath = (packagesPath as NSString).appendingPathComponent("Tests")
            let testModulePath = (pkgTestsPath as NSString).appendingPathComponent("\(module.name)Tests")
            try fileManager.createDirectory(atPath: testModulePath, withIntermediateDirectories: true)
            let testFilePath = (testModulePath as NSString).appendingPathComponent("\(module.name)Tests.swift")
            let testContents = """
            import Testing
            @testable import \(module.name)
            
            @Suite("\(module.name) tests")
            struct \(module.name)Tests {
                @Test("Example")
                func example() async throws {
                    #expect(true)
                }
            }
            """
            try testContents.write(toFile: testFilePath, atomically: true, encoding: .utf8)
            print("   \(module.name) tests generated")
        }
    }
    
    private func generatePackageSwift(in packagesPath: String, configuration: ProjectConfiguration) throws {
        let packageSwiftPath = (packagesPath as NSString).appendingPathComponent("Package.swift")
        
        let products = configuration.modules.map { module in
            ".singleTargetLibrary(\"\(module.name)\")"
        }.joined(separator: ",\n                ")
        
        let regularTargets = configuration.modules.map { module in
            ".target(name: \"\(module.name)\")"
        }.joined(separator: ",\n                ")
        
        let testTargets = configuration.modules.filter { $0.includeTests }.map { module in
            """
            .testTarget(
                name: "\(module.name)Tests",
                dependencies: ["\(module.name)"]
            )
            """
        }.joined(separator: ",\n                ")
        
        let allTargets = [regularTargets, testTargets]
            .filter { !$0.isEmpty }
            .joined(separator: ",\n                ")
        
        let packageSwiftContents = """
        // swift-tools-version: 6.1
        
        import PackageDescription
        
        let package = Package(
            name: "Main",
            platforms: [.iOS(.v\(configuration.deploymentTarget.replacingOccurrences(of: ".0", with: "")))],
            products: [
                \(products)
            ],
            targets: [
                \(allTargets)
            ]
        )
        
        extension Product {
            static func singleTargetLibrary(_ name: String) -> Product {
                .library(name: name, targets: [name])
            }
        }
        """
        
        try packageSwiftContents.write(toFile: packageSwiftPath, atomically: true, encoding: .utf8)
    }
}
