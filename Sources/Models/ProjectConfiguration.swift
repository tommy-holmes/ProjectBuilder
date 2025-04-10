import Foundation

struct Module {
    let name: String
    let includeTests: Bool
    
    static let appFeature = Self(name: "AppFeature", includeTests: false)
}

struct ProjectConfiguration {
    let name: String
    let path: String
    let bundleIdPrefix: String
    let deploymentTarget: String
    let xcodeVersion: String
    let modules: [Module]
    
    static let `default` = Self(
        name: "",
        path: FileManager.default.urls(
            for: .desktopDirectory,
            in: .userDomainMask
        ).first?.path ?? NSHomeDirectory(),
        bundleIdPrefix: "com.example",
        deploymentTarget: "15.0",
        xcodeVersion: "16.3",
        modules: [.appFeature]
    )
    
    init(
        name: String,
        path: String,
        bundleIdPrefix: String,
        deploymentTarget: String,
        xcodeVersion: String,
        modules: [Module]
    ) {
        self.name = name
        self.path = path
        self.bundleIdPrefix = bundleIdPrefix
        self.deploymentTarget = deploymentTarget
        self.xcodeVersion = xcodeVersion
        self.modules = [.appFeature] + modules
    }
} 
