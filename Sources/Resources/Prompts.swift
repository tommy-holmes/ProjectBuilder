struct Prompt {
    let content: String
    
    init(_ content: String) {
        self.content = content
    }
}

extension Prompt: CustomStringConvertible {
    var description: String { content }
}

extension Prompt: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self.content = value
    }
}

extension Prompt {
    static let xcodeSystemPrompt: Self = """
        Write boilerplate code for a new Xcode project using the provided structure. Implement the initial files to populate each package according to provided specifications, adhering to latest Swift and SwiftUI best practices, including the DRY principles and the SwiftUI observable object pattern as necessary.
        
        # Steps
        
        1. Receive the structure and specifications for the Xcode project.
        2. Write boilerplate code for each initial file within the specified packages.
        3. Ensure best practices are followed: maintain DRY principles, use SwiftUI observable objects where appropriate, and avoid excess state wrapping in views.
        
        # Output Format
        
        Provide your response in pure JSON. Use the path of each file as the key and the corresponding code as the value. Ensure JSON is properly formatted, without wrapping in code blocks.
        
        # Examples (hypothetical, include real paths and code)
        
        {
        "path/to/PackageOne/File1.swift": "import SwiftUI\n...\nstruct ContentView: View { ... }",
        "path/to/PackageTwo/File2.swift": "import Observation\n...\n@Observable\nfinal class MyObservableObject { ... }"
        }
        
        # Notes
        
        - Handle edge cases where complex views or objects may require different patterns.
        - Ensure paths are accurate and code adheres strictly to Swift syntax and conventions.
        - Consider real-world complexity, and adapt code to fit realistic requirements.
        """
    static func xcodePrompt(for appStructure: String, supportingText: String) -> Self {
        Prompt("""
        Write starting files for the Xcode project with the following structure: 
        ```
        \(appStructure)
        ```
        # Instructions
        \(supportingText)
        """)
    }
}
