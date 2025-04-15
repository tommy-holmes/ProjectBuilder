import Foundation

/// Generates the project.yml file.
struct ProjectYMLGenerator: ComponentGenerator {
    let fileManager: FileManager
    
    func generate(with context: inout GenerationContext) throws {
        guard let appPath = context.appPath else { throw GenerationError.missingAppDirectory }
        let config = context.configuration
        let projectYmlPath = (appPath as NSString).appendingPathComponent("project.yml")
        
        let projectYmlContents = """
        name: \(config.name)
        options:
          bundleIdPrefix: \(config.bundleIdPrefix)
          deploymentTarget:
            iOS: \(config.deploymentTarget)
          xcodeVersion: "\(config.xcodeVersion)"
        settings:
          base:
            INFOPLIST_FILE: Sources/Info.plist
            PRODUCT_BUNDLE_IDENTIFIER: \(config.bundleIdPrefix).\(config.name.lowercased())
        targets:
          \(config.name):
            type: application
            platform: iOS
            sources:
              - path: Sources
            settings:
              base:
                INFOPLIST_FILE: Sources/Info.plist
                PRODUCT_BUNDLE_IDENTIFIER: \(config.bundleIdPrefix).\(config.name.lowercased())
        """
        
        try projectYmlContents.write(toFile: projectYmlPath, atomically: true, encoding: .utf8)
        
        print("✅ project.yml generated")
    }
}
