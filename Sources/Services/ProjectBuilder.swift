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
You are to write the starting code for a SwiftUI iOS project that targets iOS \(configuration.deploymentTarget). 

# Brief
The app allows a software engineer to record their daily scrums. It consists of:

## Scrum list
The main screen of the app displays a summary of each of the user’s daily scrums. Users can tap a row in the list to view the details of a scrum or create a new scrum by tapping a button in the navigation bar.

## Scrum detail and edit
The detail screen shows more information about a scrum, including the name of each attendee and a list of previous meetings. Users can modify any of the scrum’s attributes by tapping a button in the navigation bar. The edit screen includes a picker with which users can change the color theme of each meeting. Tapping a button the top of the list of attributes starts a new meeting timer.

## Meeting timer
The progress bar at the top of the meeting timer shows the elapsed and remaining time for the meeting. The app displays the name of the current speaker in the center of the screen and a button to advance to the next attendee at the bottom of the screen.
Segments in a circular progress ring represent each attendee. When an attendee uses all their time, Scrumdinger plays a “ding” sound and adds a new segment to the ring. The meeting ends when the ring is full.

# Modules
- AppFeature: The AppView in the module should have a TabView to each of the feature's root views. This should also hold any top level AppState like what tab is selected. 
- RecordScrumFeature: should provide a UI that allows the user to start, pause and stop a meeting timer, with all the features listed in the meeting timer section in the brief. The timer should have a seconds elapsed and seconds remaining counters and then when you stop the meeting it saves to the history. Make the UI as clear and accessible as possible. 
- ScrumHistoryFeature: is presented in another tab, and has a list of previously saved scrums where the user can scroll through view a detail view and delete any from the list. If the user drills into a scrum, they can edit the metadata associted with that scrum in a modal that then saves once the user taps save in the navigation stack. 
- SharedModels: Any types and models that are shared thoughout the app, like a `Scrum` or an `Attendee`. These types must include any protocol conformances that would make sense to represent those concepts like being able to identify a `Scrum`. 
- DesignSystem: Any fonts and colors that will be used to design the app. For now use anything that you think makes sense but make it very easy to iterate on. Leverage SwiftUI for inspiration, ideally using API close to the built in ones like `.font(.headline)` and `.foregroundStyle(Color.red)`, etc. This should only contain primitive colors and fonts with no knowlegde of how the wider system works. 

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
