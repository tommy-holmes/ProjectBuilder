import Foundation

/// Generates the Xcode workspace.
struct WorkspaceGenerator: ComponentGenerator {
    let fileManager: FileManager
    
    func generate(with context: inout GenerationContext) throws {
        guard let projectPath = context.projectPath else { throw GenerationError.missingProjectDirectory }
        let appName = context.configuration.name
        let workspacePath = (projectPath as NSString).appendingPathComponent("Main.xcworkspace")
        let contentsPath = (workspacePath as NSString).appendingPathComponent("contents.xcworkspacedata")
        
        try fileManager.createDirectory(atPath: workspacePath, withIntermediateDirectories: true)
        
        let workspaceContents = """
        <?xml version="1.0" encoding="UTF-8"?>
        <Workspace version = "1.0">
            <FileRef location = "group:Packages"/>
            <FileRef location = "group:Apps/\(appName)/\(appName).xcodeproj"/>
        </Workspace>
        """
        try workspaceContents.write(toFile: contentsPath, atomically: true, encoding: .utf8)
        
        print("✅ Workspace generated")
    }
}
