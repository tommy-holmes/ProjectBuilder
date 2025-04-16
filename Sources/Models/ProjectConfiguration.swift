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
        bundleIdPrefix: "com.tomholmes",
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

extension ProjectConfiguration: CustomStringConvertible {
    var description: String {
        var structure = ""
        
        structure += "  ├── Apps\n"
        structure += "  │   └── Sources\n"
        structure += "  │       └── App.swift\n"
        structure += "  │       ├── ContentView.swift\n"
        structure += "  │       └── Info.plist\n"
        structure += "  │   ├── project.yml\n"
        structure += "  │       └── \(name).xcodeproj\n"
        
        structure += "  ├── Packages\n"
        structure += "  │   ├── Package.swift\n"
        if !modules.isEmpty {
            structure += "  │   ├── Sources\n"
            for module in modules {
                structure += "  │   │   ├── \(module.name)\n"
            }
            let testModules = modules.filter { $0.includeTests }
            if !testModules.isEmpty {
                structure += "  │   ├── Tests\n"
                for module in testModules {
                    structure += "  │   │   ├── \(module.name)Tests\n"
                }
            }
        }
        
        structure += "  └── Main.xcworkspace"
        
        return structure
    }
}
