import Foundation

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
