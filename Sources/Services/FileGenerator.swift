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
        let projectPath = try createProjectDirectory(at: configuration.path, name: configuration.name)
        let appPath = try createAppDirectory(in: projectPath, name: configuration.name)
        let sourcesPath = try createSourcesDirectory(in: appPath)
        
        try generateWorkspace(in: projectPath, appName: configuration.name)
        try generateProjectYML(in: appPath, configuration: configuration)
        try generateSourceFiles(in: sourcesPath, configuration: configuration)
    }
    
    private func createProjectDirectory(at path: String, name: String) throws -> String {
        let projectPath = (path as NSString).appendingPathComponent(name)
        try fileManager.createDirectory(atPath: projectPath, withIntermediateDirectories: true)
        
        // Create Apps and Packages directories
        let appsPath = (projectPath as NSString).appendingPathComponent("Apps")
        let packagesPath = (projectPath as NSString).appendingPathComponent("Packages")
        try fileManager.createDirectory(atPath: appsPath, withIntermediateDirectories: true)
        try fileManager.createDirectory(atPath: packagesPath, withIntermediateDirectories: true)
        
        return projectPath
    }
    
    private func createAppDirectory(in projectPath: String, name: String) throws -> String {
        let appsPath = (projectPath as NSString).appendingPathComponent("Apps")
        let appPath = (appsPath as NSString).appendingPathComponent(name)
        try fileManager.createDirectory(atPath: appPath, withIntermediateDirectories: true)
        return appPath
    }
    
    private func createSourcesDirectory(in appPath: String) throws -> String {
        let sourcesPath = (appPath as NSString).appendingPathComponent("Sources")
        try fileManager.createDirectory(atPath: sourcesPath, withIntermediateDirectories: true)
        return sourcesPath
    }
    
    private func generateWorkspace(in projectPath: String, appName: String) throws {
        let workspacePath = (projectPath as NSString).appendingPathComponent("Main.xcworkspace")
        let contentsPath = (workspacePath as NSString).appendingPathComponent("contents.xcworkspacedata")
        
        try fileManager.createDirectory(atPath: workspacePath, withIntermediateDirectories: true)
        
        let workspaceContents = """
        <?xml version="1.0" encoding="UTF-8"?>
        <Workspace
           version = "1.0">
           <FileRef
              location = "group:Apps/\(appName)/\(appName).xcodeproj">
           </FileRef>
        </Workspace>
        """
        
        try workspaceContents.write(toFile: contentsPath, atomically: true, encoding: .utf8)
    }
    
    private func generateProjectYML(in appPath: String, configuration: ProjectConfiguration) throws {
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
        try generateInfoPlist(in: sourcesPath, configuration: configuration)
        try generateAppSwift(in: sourcesPath, configuration: configuration)
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
} 