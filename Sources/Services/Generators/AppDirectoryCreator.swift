import Foundation

/// Creates the app-specific directory.
struct AppDirectoryCreator: ComponentGenerator {
    let fileManager: FileManager
    
    func generate(with context: inout GenerationContext) throws {
        guard let projectPath = context.projectPath else { throw GenerationError.missingProjectDirectory }
        let appsPath = (projectPath as NSString).appendingPathComponent("Apps")
        let appPath = (appsPath as NSString).appendingPathComponent(context.configuration.name)
        try fileManager.createDirectory(atPath: appPath, withIntermediateDirectories: true)
        context.appPath = appPath
        
        print("✅ App directory created at: \(appPath)")
    }
}
