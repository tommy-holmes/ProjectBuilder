import Foundation

/// Creates the project directory and its basic structure.
struct ProjectDirectoryCreator: ComponentGenerator {
    let fileManager: FileManager
    
    func generate(with context: inout GenerationContext) throws {
        let config = context.configuration
        let projectPath = (config.path as NSString).appendingPathComponent(config.name)
        
        try fileManager.createDirectory(atPath: projectPath, withIntermediateDirectories: true)
        
        // Create the "Apps" and "Packages" directories.
        let appsPath = (projectPath as NSString).appendingPathComponent("Apps")
        try fileManager.createDirectory(atPath: appsPath, withIntermediateDirectories: true)
        
        let packagesPath = (projectPath as NSString).appendingPathComponent("Packages")
        try fileManager.createDirectory(atPath: packagesPath, withIntermediateDirectories: true)
        
        context.projectPath = projectPath
        context.packagesPath = packagesPath
        
        print("✅ Project directory created at: \(projectPath)")
    }
}
