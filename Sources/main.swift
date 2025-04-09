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

let configuration = ProjectConfiguration(
    name: projectName,
    path: path,
    bundleIdPrefix: "com.example",
    deploymentTarget: "15.0",
    xcodeVersion: "15.0"
)

let builder = ProjectBuilder()

do {
    try builder.buildProject(with: configuration)
} catch {
    print("❌ Error creating project: \(error.localizedDescription)")
    print("\nTry using a different path where you have write permissions.")
    exit(1)
}