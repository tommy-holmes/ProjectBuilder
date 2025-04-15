import Foundation

// MARK: - Supporting Types & Errors

/// Represents an error during generation.
enum GenerationError: Error {
    case missingProjectDirectory
    case missingAppDirectory
    case missingSourcesDirectory
    case missingPackagesDirectory
}

/// The shared context passed among the component generators.
struct GenerationContext {
    let configuration: ProjectConfiguration
    var projectPath: String?
    var appPath: String?
    var sourcesPath: String?
    var packagesPath: String?
}

// MARK: - Composable FileGenerator

struct FileGenerator: FileGenerating {
    private let fileManager: FileManager
    private let generators: [ComponentGenerator]
    
    init(fileManager: FileManager = .default,
         generators: [ComponentGenerator] = FileGenerator.defaultGenerators(fileManager: .default)) {
        self.fileManager = fileManager
        self.generators = generators
    }
    
    func generateFiles(for configuration: ProjectConfiguration) throws {
        print("📦 Starting project generation...")
        var context = GenerationContext(configuration: configuration)
        try generators.forEach { try $0.generate(with: &context) }
    }
    
    /// Provides a default array of generators to compose the overall workflow.
    static func defaultGenerators(fileManager: FileManager) -> [ComponentGenerator] {
        return [
            ProjectDirectoryCreator(fileManager: fileManager),
            AppDirectoryCreator(fileManager: fileManager),
            SourcesDirectoryCreator(fileManager: fileManager),
            WorkspaceGenerator(fileManager: fileManager),
            ProjectYMLGenerator(fileManager: fileManager),
            SourceFilesGenerator(fileManager: fileManager),
            PackageGenerator(fileManager: fileManager)
        ]
    }
}
