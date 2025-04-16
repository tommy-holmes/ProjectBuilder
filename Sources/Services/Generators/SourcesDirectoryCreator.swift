import Foundation

/// Creates the Sources directory for the app.
struct SourcesDirectoryCreator: ComponentGenerator {
    let fileManager: FileManager
    
    func generate(with context: inout GenerationContext) throws {
        guard let appPath = context.appPath else { throw GenerationError.missingAppDirectory }
        let sourcesPath = (appPath as NSString).appendingPathComponent("Sources")
        try fileManager.createDirectory(atPath: sourcesPath, withIntermediateDirectories: true)
        context.sourcesPath = sourcesPath
        
        print("✅ Sources directory created at: \(sourcesPath)")
    }
}
