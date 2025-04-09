import Foundation

struct ProjectBuilder {
    private let fileGenerator: FileGenerating
    private let xcodegenRunner: XcodegenRunning
    
    init(
        fileGenerator: FileGenerating = FileGenerator(),
        xcodegenRunner: XcodegenRunning = XcodegenRunner()
    ) {
        self.fileGenerator = fileGenerator
        self.xcodegenRunner = xcodegenRunner
    }
    
    func buildProject(with configuration: ProjectConfiguration) throws {
        // Generate all project files
        try fileGenerator.generateFiles(for: configuration)
        
        // Run xcodegen in the app directory
        let appURL = URL(fileURLWithPath: configuration.path)
            .appendingPathComponent(configuration.name)
            .appendingPathComponent("Apps")
            .appendingPathComponent(configuration.name)
        try xcodegenRunner.runXcodegen(in: appURL.path)
        
        printProjectStructure(for: configuration)
    }
    
    private func printProjectStructure(for configuration: ProjectConfiguration) {
        let projectPath = URL(fileURLWithPath: configuration.path)
            .appendingPathComponent(configuration.name)
            .path
        print("✅ Created project structure at: \(projectPath)")
        print("  ├── Apps")
        print("  │   └── \(configuration.name)")
        print("  │       ├── Sources")
        print("  │       │   ├── App.swift")
        print("  │       │   ├── ContentView.swift")
        print("  │       │   └── Info.plist")
        print("  │       ├── project.yml")
        print("  │       └── \(configuration.name).xcodeproj")
        print("  ├── Packages")
        print("  └── Main.xcworkspace")
    }
}

func printUsage() {
    print("""
    Usage: ProjectBuilder <project-name> [path] [options]
    
    Arguments:
      project-name    The name of the project to create
      path           (Optional) The path where the project should be created
                    Defaults to the user's home directory
    
    Options:
      --bundle-id-prefix <prefix>  (Optional) Bundle ID prefix (default: com.example)
      --deployment-target <version> (Optional) iOS deployment target (default: 15.0)
      --xcode-version <version>    (Optional) Xcode version (default: 16.3)
    
    Examples:
      ProjectBuilder MyProject
      ProjectBuilder MyProject ~/Projects
      ProjectBuilder MyProject --bundle-id-prefix com.mycompany --deployment-target 14.0
      ProjectBuilder MyProject ~/Projects --xcode-version 15.0
    
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
var path = defaultPath
var bundleIdPrefix = "com.example"
var deploymentTarget = "15.0"
var xcodeVersion = "16.3"

// Parse arguments
var currentIndex = 2
while currentIndex < CommandLine.arguments.count {
    let arg = CommandLine.arguments[currentIndex]
    
    switch arg {
    case "--bundle-id-prefix":
        guard currentIndex + 1 < CommandLine.arguments.count else {
            print("❌ Error: Missing value for --bundle-id-prefix")
            printUsage()
            exit(1)
        }
        bundleIdPrefix = CommandLine.arguments[currentIndex + 1]
        currentIndex += 2
        
    case "--deployment-target":
        guard currentIndex + 1 < CommandLine.arguments.count else {
            print("❌ Error: Missing value for --deployment-target")
            printUsage()
            exit(1)
        }
        deploymentTarget = CommandLine.arguments[currentIndex + 1]
        currentIndex += 2
        
    case "--xcode-version":
        guard currentIndex + 1 < CommandLine.arguments.count else {
            print("❌ Error: Missing value for --xcode-version")
            printUsage()
            exit(1)
        }
        xcodeVersion = CommandLine.arguments[currentIndex + 1]
        currentIndex += 2
        
    default:
        // If it's not an option, it must be the path
        if currentIndex == 2 {
            path = arg
            currentIndex += 1
        } else {
            print("❌ Error: Unknown argument: \(arg)")
            printUsage()
            exit(1)
        }
    }
}

let configuration = ProjectConfiguration(
    name: projectName,
    path: path,
    bundleIdPrefix: bundleIdPrefix,
    deploymentTarget: deploymentTarget,
    xcodeVersion: xcodeVersion
)

let builder = ProjectBuilder()

do {
    try builder.buildProject(with: configuration)
} catch {
    print("❌ Error creating project: \(error.localizedDescription)")
    print("\nTry using a different path where you have write permissions.")
    exit(1)
}