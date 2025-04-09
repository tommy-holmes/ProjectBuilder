import Foundation

struct ProjectConfiguration {
    let name: String
    let path: String
    let bundleIdPrefix: String
    let deploymentTarget: String
    let xcodeVersion: String
    
    static let `default` = Self(
        name: "",
        path: NSHomeDirectory(),
        bundleIdPrefix: "com.example",
        deploymentTarget: "15.0",
        xcodeVersion: "15.0"
    )
} 
