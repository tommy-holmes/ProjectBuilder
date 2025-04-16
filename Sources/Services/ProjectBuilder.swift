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
    
    func buildProjectSkeletion(with configuration: ProjectConfiguration) throws {
        try fileGenerator.generateFiles(for: configuration)
        
        let appURL = URL(fileURLWithPath: configuration.path)
            .appendingPathComponent(configuration.name)
            .appendingPathComponent("Apps")
            .appendingPathComponent(configuration.name)
        
        try xcodegenRunner.runXcodegen(in: appURL.path)
        print("✅ Created project structure at: \(appURL.path)\n", configuration.description)
    }
    
    func generateBoilerplate(with configuration: ProjectConfiguration) async throws {
        let boilerplateJson = try await OpenAIClient.fetchResponse(
            for: .xcodePrompt(
                for: configuration.description,
                supportingText: """
The TradeFeature should contain models like `Money` and a view that lets you input a trade. The ExploreFeature should contain models like `Asset` and a view that lists available assets. Just focus on generating the files for the packages not the main app. 
"""
            ),
            withSystemPrompt: .xcodeSystemPrompt
        )
        
        let jsonData = boilerplateJson.data(using: .utf8)
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .iso8601
        let boilerplateDict = try jsonDecoder.decode([String: String].self, from: jsonData!)
        print("✅ Generated boilerplate code:\n", boilerplateDict)
        
        let projectRoot = URL(fileURLWithPath: configuration.path)
            .appendingPathComponent(configuration.name)
        
        for file in boilerplateDict {
            let filePath = projectRoot.appendingPathComponent(file.key)
            let directory = filePath.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            try file.value.write(to: filePath, atomically: true, encoding: .utf8)
            print("✅ Created file at: \(filePath.path)")
        }
    }
}
