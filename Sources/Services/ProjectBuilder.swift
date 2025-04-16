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
                supportingInstructions: """
The CounterFeature should provide a UI that allows the user to increment and decrement an Int that is displayed, with a button to store a favorite and remove it is already a favorite. 

The FavoritesFeature is presented in another tab, and has a list of favorite numbers where the user can scroll throught and delete any. 

The AppView in the AppFeature should have a TabView to each of the feature's root views. 

Make the UI as pretty and user friendly as possible whilst making it accessible, leverging built in SwiftUI features. 
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
