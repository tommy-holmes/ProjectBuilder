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
        
        print(configuration.description)
    }
}
