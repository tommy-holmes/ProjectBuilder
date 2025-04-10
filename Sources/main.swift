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

// Main execution
do {
    print("🔍 Parsing command line arguments...")
    let (
        projectName, 
        path, 
        bundleIdPrefix, 
        deploymentTarget, 
        xcodeVersion,
        modules
    ) = try ArgumentParser.parse(CommandLine.arguments)
    
    print("✅ Successfully parsed arguments:")
    print("   Project Name: \(projectName)")
    print("   Path: \(path)")
    print("   Bundle ID Prefix: \(bundleIdPrefix)")
    print("   Deployment Target: \(deploymentTarget)")
    print("   Xcode Version: \(xcodeVersion)")
    if !modules.isEmpty {
        print("   Modules:")
        for module in modules {
            print("     - \(module.name)\(module.includeTests ? " (with tests)" : "")")
        }
    }
    
    let configuration = ProjectConfiguration(
        name: projectName,
        path: path,
        bundleIdPrefix: bundleIdPrefix,
        deploymentTarget: deploymentTarget,
        xcodeVersion: xcodeVersion,
        modules: modules
    )
    
    print("🏗️ Starting project builder...")
    let builder = ProjectBuilder()
    try builder.buildProject(with: configuration)
    print("✨ Project generation completed successfully!")
} catch let error as ArgumentError {
    print("❌ Error: \(error.localizedDescription)")
    HelpText.printUsage()
    exit(1)
} catch {
    print("❌ Error creating project: \(error.localizedDescription)")
    print("\nTry using a different path where you have write permissions.")
    exit(1)
}
