import Foundation

protocol FileGenerating {
    func generateFiles(for configuration: ProjectConfiguration) throws
}

struct FileGenerator: FileGenerating {
    private let fileManager: FileManager
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    func generateFiles(for configuration: ProjectConfiguration) throws {
        print("📦 Starting project generation...")
        print("   Project name: \(configuration.name)")
        print("   Path: \(configuration.path)")
        print("   Bundle ID Prefix: \(configuration.bundleIdPrefix)")
        print("   Deployment Target: iOS \(configuration.deploymentTarget)")
        print("   Xcode Version: \(configuration.xcodeVersion)")
        
        let projectPath = try createProjectDirectory(at: configuration.path, name: configuration.name)
        print("✅ Created project directory at: \(projectPath)")
        
        let appPath = try createAppDirectory(in: projectPath, name: configuration.name)
        print("✅ Created app directory at: \(appPath)")
        
        let sourcesPath = try createSourcesDirectory(in: appPath)
        print("✅ Created sources directory at: \(sourcesPath)")
        
        let packagesPath = try createPackagesDirectory(in: projectPath)
        print("✅ Created packages directory at: \(packagesPath)")
        
        print("📝 Creating package directories...")
        try createPackageDirectories(in: packagesPath, configuration: configuration)
        print("✅ Created package directories")
        
        print("📝 Generating workspace...")
        try generateWorkspace(in: projectPath, appName: configuration.name)
        print("✅ Generated workspace")
        
        print("📝 Generating project.yml...")
        try generateProjectYML(in: appPath, configuration: configuration)
        print("✅ Generated project.yml")
        
        print("📝 Generating source files...")
        try generateSourceFiles(in: sourcesPath, configuration: configuration)
        print("✅ Generated source files")
        
        print("📝 Generating Package.swift...")
        try generatePackageSwift(in: packagesPath, configuration: configuration)
        print("✅ Generated Package.swift")
    }
    
    private func createProjectDirectory(at path: String, name: String) throws -> String {
        print("   Creating project directory...")
        let projectPath = (path as NSString).appendingPathComponent(name)
        try fileManager.createDirectory(atPath: projectPath, withIntermediateDirectories: true)
        
        // Create Apps and Packages directories
        let appsPath = (projectPath as NSString).appendingPathComponent("Apps")
        let packagesPath = (projectPath as NSString).appendingPathComponent("Packages")
        print("   Creating Apps directory...")
        try fileManager.createDirectory(atPath: appsPath, withIntermediateDirectories: true)
        print("   Creating Packages directory...")
        try fileManager.createDirectory(atPath: packagesPath, withIntermediateDirectories: true)
        
        return projectPath
    }
    
    private func createAppDirectory(in projectPath: String, name: String) throws -> String {
        print("   Creating app directory...")
        let appsPath = (projectPath as NSString).appendingPathComponent("Apps")
        let appPath = (appsPath as NSString).appendingPathComponent(name)
        try fileManager.createDirectory(atPath: appPath, withIntermediateDirectories: true)
        return appPath
    }
    
    private func createSourcesDirectory(in appPath: String) throws -> String {
        print("   Creating sources directory...")
        let sourcesPath = (appPath as NSString).appendingPathComponent("Sources")
        try fileManager.createDirectory(atPath: sourcesPath, withIntermediateDirectories: true)
        return sourcesPath
    }
    
    private func createPackagesDirectory(in projectPath: String) throws -> String {
        print("   Creating packages directory...")
        let packagesPath = (projectPath as NSString).appendingPathComponent("Packages")
        try fileManager.createDirectory(atPath: packagesPath, withIntermediateDirectories: true)
        return packagesPath
    }
    
    private func generateWorkspace(in projectPath: String, appName: String) throws {
        print("   Generating workspace contents...")
        let workspacePath = (projectPath as NSString).appendingPathComponent("Main.xcworkspace")
        let contentsPath = (workspacePath as NSString).appendingPathComponent("contents.xcworkspacedata")
        
        try fileManager.createDirectory(atPath: workspacePath, withIntermediateDirectories: true)
        
        let workspaceContents = """
        <?xml version="1.0" encoding="UTF-8"?>
        <Workspace
           version = "1.0">
           <FileRef
              location = "group:Packages">
           </FileRef>
           <FileRef
              location = "group:Apps/\(appName)/\(appName).xcodeproj">
           </FileRef>
        </Workspace>
        """
        
        try workspaceContents.write(toFile: contentsPath, atomically: true, encoding: .utf8)
    }
    
    private func generateProjectYML(in appPath: String, configuration: ProjectConfiguration) throws {
        print("   Generating project.yml contents...")
        let projectYmlPath = (appPath as NSString).appendingPathComponent("project.yml")
        let projectYmlContents = """
        name: \(configuration.name)
        options:
          bundleIdPrefix: \(configuration.bundleIdPrefix)
          deploymentTarget:
            iOS: \(configuration.deploymentTarget)
          xcodeVersion: "\(configuration.xcodeVersion)"
        settings:
          base:
            INFOPLIST_FILE: Sources/Info.plist
            PRODUCT_BUNDLE_IDENTIFIER: \(configuration.bundleIdPrefix).\(configuration.name.lowercased())
        targets:
          \(configuration.name):
            type: application
            platform: iOS
            sources:
              - path: Sources
            settings:
              base:
                INFOPLIST_FILE: Sources/Info.plist
                PRODUCT_BUNDLE_IDENTIFIER: \(configuration.bundleIdPrefix).\(configuration.name.lowercased())
        """
        
        try projectYmlContents.write(toFile: projectYmlPath, atomically: true, encoding: .utf8)
    }
    
    private func generateSourceFiles(in sourcesPath: String, configuration: ProjectConfiguration) throws {
        print("   Generating Info.plist...")
        try generateInfoPlist(in: sourcesPath, configuration: configuration)
        print("   Generating App.swift...")
        try generateAppSwift(in: sourcesPath, configuration: configuration)
        print("   Generating ContentView.swift...")
        try generateContentView(in: sourcesPath)
    }
    
    private func generateInfoPlist(in sourcesPath: String, configuration: ProjectConfiguration) throws {
        let infoPlistPath = (sourcesPath as NSString).appendingPathComponent("Info.plist")
        let infoPlistContents = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>CFBundleDevelopmentRegion</key>
            <string>$(DEVELOPMENT_LANGUAGE)</string>
            <key>CFBundleExecutable</key>
            <string>$(EXECUTABLE_NAME)</string>
            <key>CFBundleIdentifier</key>
            <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
            <key>CFBundleInfoDictionaryVersion</key>
            <string>6.0</string>
            <key>CFBundleName</key>
            <string>\(configuration.name)</string>
            <key>CFBundlePackageType</key>
            <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
            <key>CFBundleShortVersionString</key>
            <string>1.0</string>
            <key>CFBundleVersion</key>
            <string>1</string>
            <key>LSRequiresIPhoneOS</key>
            <true/>
            <key>UIApplicationSceneManifest</key>
            <dict>
                <key>UIApplicationSupportsMultipleScenes</key>
                <false/>
            </dict>
            <key>UILaunchScreen</key>
            <dict/>
            <key>UIRequiredDeviceCapabilities</key>
            <array>
                <string>armv7</string>
            </array>
            <key>UISupportedInterfaceOrientations</key>
            <array>
                <string>UIInterfaceOrientationPortrait</string>
                <string>UIInterfaceOrientationLandscapeLeft</string>
                <string>UIInterfaceOrientationLandscapeRight</string>
            </array>
        </dict>
        </plist>
        """
        
        try infoPlistContents.write(toFile: infoPlistPath, atomically: true, encoding: .utf8)
    }
    
    private func generateAppSwift(in sourcesPath: String, configuration: ProjectConfiguration) throws {
        let appSwiftPath = (sourcesPath as NSString).appendingPathComponent("App.swift")
        let appSwiftContents = """
        import SwiftUI

        @main
        struct \(configuration.name)App: App {
            var body: some Scene {
                WindowGroup {
                    ContentView()
                }
            }
        }
        """
        
        try appSwiftContents.write(toFile: appSwiftPath, atomically: true, encoding: .utf8)
    }
    
    private func generateContentView(in sourcesPath: String) throws {
        let contentViewPath = (sourcesPath as NSString).appendingPathComponent("ContentView.swift")
        let contentViewContents = """
        import SwiftUI

        struct ContentView: View {
            var body: some View {
                VStack {
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Hello, world!")
                }
                .padding()
            }
        }

        #Preview {
            ContentView()
        }
        """
        
        try contentViewContents.write(toFile: contentViewPath, atomically: true, encoding: .utf8)
    }
    
    private func createPackageDirectories(in packagesPath: String, configuration: ProjectConfiguration) throws {
        print("   Creating package source directories...")
        let sourcesPath = (packagesPath as NSString).appendingPathComponent("Sources")
        let testsPath = (packagesPath as NSString).appendingPathComponent("Tests")
        
        print("   Creating Sources directory at: \(sourcesPath)")
        try fileManager.createDirectory(atPath: sourcesPath, withIntermediateDirectories: true)
        
        print("   Creating Tests directory at: \(testsPath)")
        try fileManager.createDirectory(atPath: testsPath, withIntermediateDirectories: true)
        
        // Generate all modules
        for module in configuration.modules {
            try generate(module: module.name, includeTests: module.includeTests, in: packagesPath)
        }
    }
    
    private func generate(module: String, includeTests: Bool, in packagesPath: String) throws {
        let sourcesPath = (packagesPath as NSString).appendingPathComponent("Sources")
        let modulePath = (sourcesPath as NSString).appendingPathComponent(module)
        
        print("   Creating \(module) directory at: \(modulePath)")
        try fileManager.createDirectory(atPath: modulePath, withIntermediateDirectories: true)
        
        // Generate the main module file
        let moduleFilePath = (modulePath as NSString).appendingPathComponent("\(module)View.swift")
        print("   Writing \(module)View.swift to: \(moduleFilePath)")
        let moduleContents = """
        import SwiftUI

        public struct \(module)View: View {
            public init() { }
            
            public var body: some View {
                Text("Hello, World!")
            }
        }
        """
        try moduleContents.write(toFile: moduleFilePath, atomically: true, encoding: .utf8)
        
        if includeTests {
            let testsPath = (packagesPath as NSString).appendingPathComponent("Tests")
            let testModulePath = (testsPath as NSString).appendingPathComponent("\(module)Tests")
            
            print("   Creating \(module)Tests directory at: \(testModulePath)")
            try fileManager.createDirectory(atPath: testModulePath, withIntermediateDirectories: true)
            
            // Generate the test file
            let testFilePath = (testModulePath as NSString).appendingPathComponent("\(module)Tests.swift")
            print("   Writing \(module)Tests.swift to: \(testFilePath)")
            let testContents = """
            import Testing
            @testable import \(module)

            @Suite("\(module) tests")
            struct \(module)Tests {
                @Test("Example")
                func example() async throws {
                    #expect(true)
                }
            }
            """
            try testContents.write(toFile: testFilePath, atomically: true, encoding: .utf8)
        }
    }
    
    private func generatePackageSwift(in packagesPath: String, configuration: ProjectConfiguration) throws {
        print("   Generating Package.swift contents...")
        let packageSwiftPath = (packagesPath as NSString).appendingPathComponent("Package.swift")
        
        // Generate products and targets for all modules
        let products = configuration.modules.map { module in
            ".singleTargetLibrary(\"\(module.name)\")"
        }.joined(separator: ",\n            ")
        
        // Separate regular targets and test targets
        let regularTargets = configuration.modules.map { module in
            ".target(\n                name: \"\(module.name)\"\n            )"
        }.joined(separator: ",\n            ")
        
        let testTargets = configuration.modules
            .filter { $0.includeTests }
            .map { module in
                """
                .testTarget(
                    name: "\(module.name)Tests",
                    dependencies: ["\(module.name)"]
                )
                """
            }
            .joined(separator: ",\n            ")
        
        // Combine targets, ensuring test targets come last
        let allTargets = [regularTargets, testTargets]
            .filter { !$0.isEmpty }
            .joined(separator: ",\n            ")
        
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
        
        try packageSwiftContents.write(toFile: packageSwiftPath, atomically: true, encoding: String.Encoding.utf8)
    }
} 
