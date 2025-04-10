import Foundation

struct ArgumentParser {
    static func parse(_ arguments: [String]) throws -> (
        projectName: String,
        path: String,
        bundleIdPrefix: String,
        deploymentTarget: String,
        xcodeVersion: String,
        modules: [Module]
    ) {
        guard arguments.count >= 2 else {
            throw ArgumentError.insufficientArguments
        }
        
        let projectName = arguments[1]
        var path = NSHomeDirectory()
        var bundleIdPrefix = "com.example"
        var deploymentTarget = "15.0"
        var xcodeVersion = "16.3"
        var modules: [Module] = []
        
        var currentIndex = 2
        while currentIndex < arguments.count {
            let arg = arguments[currentIndex]
            
            switch arg {
            case "--bundle-id-prefix":
                guard currentIndex + 1 < arguments.count else {
                    throw ArgumentError.missingValue(for: arg)
                }
                bundleIdPrefix = arguments[currentIndex + 1]
                currentIndex += 2
                
            case "--deployment-target":
                guard currentIndex + 1 < arguments.count else {
                    throw ArgumentError.missingValue(for: arg)
                }
                deploymentTarget = arguments[currentIndex + 1]
                currentIndex += 2
                
            case "--xcode-version":
                guard currentIndex + 1 < arguments.count else {
                    throw ArgumentError.missingValue(for: arg)
                }
                xcodeVersion = arguments[currentIndex + 1]
                currentIndex += 2
                
            case "--module":
                guard currentIndex + 1 < arguments.count else {
                    throw ArgumentError.missingValue(for: arg)
                }
                let moduleName = arguments[currentIndex + 1]
                let includeTests = currentIndex + 2 < arguments.count && arguments[currentIndex + 2] == "--include-tests"
                modules.append(Module(name: moduleName, includeTests: includeTests))
                currentIndex += includeTests ? 3 : 2
                
            default:
                // If it's not an option, it must be the path
                if currentIndex == 2 {
                    path = arg
                    currentIndex += 1
                } else {
                    throw ArgumentError.unknownArgument(arg)
                }
            }
        }
        
        return (
            projectName: projectName,
            path: path,
            bundleIdPrefix: bundleIdPrefix,
            deploymentTarget: deploymentTarget,
            xcodeVersion: xcodeVersion,
            modules: modules
        )
    }
}

enum ArgumentError: Error {
    case insufficientArguments
    case missingValue(for: String)
    case unknownArgument(String)
    
    var localizedDescription: String {
        switch self {
        case .insufficientArguments:
            return "Insufficient arguments provided"
        case .missingValue(let argument):
            return "Missing value for argument: \(argument)"
        case .unknownArgument(let argument):
            return "Unknown argument: \(argument)"
        }
    }
} 