import Foundation

/// Generates the source files such as Info.plist, App.swift, and ContentView.swift.
struct SourceFilesGenerator: ComponentGenerator {
    let fileManager: FileManager
    
    func generate(with context: inout GenerationContext) throws {
        guard let sourcesPath = context.sourcesPath else { throw GenerationError.missingSourcesDirectory }
        let config = context.configuration
        
        try generateInfoPlist(in: sourcesPath, with: config)
        try generateAppSwift(in: sourcesPath, with: config)
        try generateContentView(in: sourcesPath)
        
        print("✅ Source files generated")
    }
    
    private func generateInfoPlist(in sourcesPath: String, with config: ProjectConfiguration) throws {
        let infoPlistPath = (sourcesPath as NSString).appendingPathComponent("Info.plist")
        let infoPlistContents = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>CFBundleDevelopmentRegion</key>
            <string>$(DEVELOPMENT_LANGUAGE)</string>
            <key>CFBundleExecutable</key>
            <string>$(EXECUTABLE_NAME)</string>
            <key>CFBundleIdentifier</key>
            <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
            <key>CFBundleInfoDictionaryVersion</key>
            <string>6.0</string>
            <key>CFBundleName</key>
            <string>\(config.name)</string>
            <key>CFBundlePackageType</key>
            <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
            <key>CFBundleShortVersionString</key>
            <string>1.0</string>
            <key>CFBundleVersion</key>
            <string>1</string>
            <key>LSRequiresIPhoneOS</key>
            <true/>
            <key>UIApplicationSceneManifest</key>
            <dict>
                <key>UIApplicationSupportsMultipleScenes</key>
                <false/>
            </dict>
            <key>UILaunchScreen</key>
            <dict/>
            <key>UIRequiredDeviceCapabilities</key>
            <array>
                <string>armv7</string>
            </array>
            <key>UISupportedInterfaceOrientations</key>
            <array>
                <string>UIInterfaceOrientationPortrait</string>
                <string>UIInterfaceOrientationLandscapeLeft</string>
                <string>UIInterfaceOrientationLandscapeRight</string>
            </array>
        </dict>
        </plist>
        """
        try infoPlistContents.write(toFile: infoPlistPath, atomically: true, encoding: .utf8)
        print("   Info.plist generated")
    }
    
    private func generateAppSwift(in sourcesPath: String, with config: ProjectConfiguration) throws {
        let appSwiftPath = (sourcesPath as NSString).appendingPathComponent("App.swift")
        let appSwiftContents = """
        import SwiftUI
        
        @main
        struct \(config.name)App: App {
            var body: some Scene {
                WindowGroup {
                    ContentView()
                }
            }
        }
        """
        try appSwiftContents.write(toFile: appSwiftPath, atomically: true, encoding: .utf8)
        print("   App.swift generated")
    }
    
    private func generateContentView(in sourcesPath: String) throws {
        let contentViewPath = (sourcesPath as NSString).appendingPathComponent("ContentView.swift")
        let contentViewContents = """
        import SwiftUI
        
        struct ContentView: View {
            var body: some View {
                VStack {
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Hello, world!")
                }
                .padding()
            }
        }
        
        #Preview {
            ContentView()
        }
        """
        try contentViewContents.write(toFile: contentViewPath, atomically: true, encoding: .utf8)
        print("   ContentView.swift generated")
    }
}
