import Foundation

struct WorkspaceGenerator {
    let name: String
    let path: String
    
    func checkXcodegenInstallation() throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = ["xcodegen"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            throw NSError(domain: "WorkspaceGenerator", code: 5, 
                         userInfo: [NSLocalizedDescriptionKey: "xcodegen is not installed. Please install it using: brew install xcodegen"])
        }
    }
    
    func generate() throws {
        // Check if xcodegen is installed
        try checkXcodegenInstallation()
        
        // Convert to absolute path if it's not already
        let absolutePath = (path as NSString).expandingTildeInPath
        let fileManager = FileManager.default
        
        // Ensure the path exists and is writable
        var isDirectory: ObjCBool = false
        let pathExists = fileManager.fileExists(atPath: absolutePath, isDirectory: &isDirectory)
        
        if !pathExists {
            throw NSError(domain: "WorkspaceGenerator", code: 1, 
                         userInfo: [NSLocalizedDescriptionKey: "Path does not exist: \(absolutePath)"])
        }
        
        if !isDirectory.boolValue {
            throw NSError(domain: "WorkspaceGenerator", code: 2, 
                         userInfo: [NSLocalizedDescriptionKey: "Path is not a directory: \(absolutePath)"])
        }
        
        // Check if we have write permissions
        if !fileManager.isWritableFile(atPath: absolutePath) {
            throw NSError(domain: "WorkspaceGenerator", code: 3, 
                         userInfo: [NSLocalizedDescriptionKey: "No write permissions for path: \(absolutePath)"])
        }
        
        // Create the main project directory
        let projectPath = (absolutePath as NSString).appendingPathComponent(name)
        try fileManager.createDirectory(atPath: projectPath, withIntermediateDirectories: true)
        
        // Create Apps and Packages directories
        let appsPath = (projectPath as NSString).appendingPathComponent("Apps")
        let packagesPath = (projectPath as NSString).appendingPathComponent("Packages")
        try fileManager.createDirectory(atPath: appsPath, withIntermediateDirectories: true)
        try fileManager.createDirectory(atPath: packagesPath, withIntermediateDirectories: true)
        
        // Create app directory with project name
        let appPath = (appsPath as NSString).appendingPathComponent(name)
        try fileManager.createDirectory(atPath: appPath, withIntermediateDirectories: true)
        
        // Create workspace in the root project directory
        let workspacePath = (projectPath as NSString).appendingPathComponent("Main.xcworkspace")
        let contentsPath = (workspacePath as NSString).appendingPathComponent("contents.xcworkspacedata")
        
        // Create workspace directory
        try fileManager.createDirectory(atPath: workspacePath, withIntermediateDirectories: true)
        
        // Create workspace contents file with correct project reference
        let workspaceContents = """
        <?xml version="1.0" encoding="UTF-8"?>
        <Workspace
           version = "1.0">
           <FileRef
              location = "group:Apps/\(name)/\(name).xcodeproj">
           </FileRef>
        </Workspace>
        """
        
        try workspaceContents.write(toFile: contentsPath, atomically: true, encoding: .utf8)
        
        // Create Sources directory and files
        let sourcesPath = (appPath as NSString).appendingPathComponent("Sources")
        try fileManager.createDirectory(atPath: sourcesPath, withIntermediateDirectories: true)
        
        // Create Info.plist
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
            <string>\(name)</string>
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
        
        // Create App.swift
        let appSwiftPath = (sourcesPath as NSString).appendingPathComponent("App.swift")
        let appSwiftContents = """
        import SwiftUI

        @main
        struct \(name)App: App {
            var body: some Scene {
                WindowGroup {
                    ContentView()
                }
            }
        }
        """
        
        try appSwiftContents.write(toFile: appSwiftPath, atomically: true, encoding: .utf8)
        
        // Create ContentView.swift
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
        
        // Create project.yml for xcodegen
        let projectYmlPath = (appPath as NSString).appendingPathComponent("project.yml")
        let projectYmlContents = """
        name: \(name)
        options:
          bundleIdPrefix: com.example
          deploymentTarget:
            iOS: 15.0
          xcodeVersion: "15.0"
        settings:
          base:
            INFOPLIST_FILE: Sources/Info.plist
            PRODUCT_BUNDLE_IDENTIFIER: com.example.\(name.lowercased())
        targets:
          \(name):
            type: application
            platform: iOS
            sources:
              - path: Sources
            settings:
              base:
                INFOPLIST_FILE: Sources/Info.plist
                PRODUCT_BUNDLE_IDENTIFIER: com.example.\(name.lowercased())
        """
        
        try projectYmlContents.write(toFile: projectYmlPath, atomically: true, encoding: .utf8)
        
        // Run xcodegen in the terminal
        let task = Process()
        task.currentDirectoryURL = URL(fileURLWithPath: appPath)
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.arguments = ["-c", "xcodegen generate --spec project.yml"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        try task.run()
        task.waitUntilExit()
        
        if task.terminationStatus != 0 {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "WorkspaceGenerator", code: 4, 
                         userInfo: [NSLocalizedDescriptionKey: "Failed to generate Xcode project: \(output)"])
        }
        
        print("✅ Created project structure at: \(projectPath)")
        print("  ├── Apps")
        print("  │   └── \(name)")
        print("  │       ├── Sources")
        print("  │       │   ├── App.swift")
        print("  │       │   ├── ContentView.swift")
        print("  │       │   └── Info.plist")
        print("  │       ├── project.yml")
        print("  │       └── \(name).xcodeproj")
        print("  ├── Packages")
        print("  └── Main.xcworkspace")
    }
}

func printUsage() {
    print("""
    Usage: ProjectBuilder <project-name> [path]
    
    Arguments:
      project-name    The name of the project to create
      path           (Optional) The path where the project should be created
                    Defaults to the user's home directory
    
    Example:
      ProjectBuilder MyProject
      ProjectBuilder MyProject ~/Projects
    
    Note: This tool requires xcodegen to be installed.
    Install it using: brew install xcodegen
    """)
}

// Main execution
if CommandLine.arguments.count < 2 {
    printUsage()
    exit(1)
}

let projectName = CommandLine.arguments[1]
let defaultPath = NSHomeDirectory()
let path = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : defaultPath

let generator = WorkspaceGenerator(name: projectName, path: path)

do {
    try generator.generate()
} catch {
    print("❌ Error creating project: \(error.localizedDescription)")
    print("\nTry using a different path where you have write permissions.")
    exit(1)
}