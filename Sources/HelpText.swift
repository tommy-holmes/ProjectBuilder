import Foundation

struct HelpText {
    static let usage = """
    Usage: ProjectBuilder <project-name> [path] [options]
    
    Arguments:
      project-name    The name of the project to create
      path           (Optional) The path where the project should be created
                    Defaults to the user's home directory
    
    Options:
      --bundle-id-prefix <prefix>  (Optional) Bundle ID prefix (default: com.example)
      --deployment-target <version> (Optional) iOS deployment target (default: 15.0)
      --xcode-version <version>    (Optional) Xcode version (default: 16.3)
    
    Examples:
      ProjectBuilder MyProject
      ProjectBuilder MyProject ~/Projects
      ProjectBuilder MyProject --bundle-id-prefix com.mycompany --deployment-target 14.0
      ProjectBuilder MyProject ~/Projects --xcode-version 15.0
    
    Note: This tool requires xcodegen to be installed.
    Install it using: brew install xcodegen
    """
    
    static func printUsage() {
        print(usage)
    }
} 