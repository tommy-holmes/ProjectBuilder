import Foundation
import XcodeGenKit

protocol XcodegenRunning {
    func runXcodegen(in directory: String) throws
}

struct XcodegenRunner: XcodegenRunning {
    private let process: Process
    private let fileManager: FileManager
    
    init(process: Process = Process(), fileManager: FileManager = .default) {
        self.process = process
        self.fileManager = fileManager
    }
    
    func runXcodegen(in directory: String) throws {
        // Check if xcodegen is installed
        let whichProcess = Process()
        whichProcess.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        whichProcess.arguments = ["xcodegen"]
        
        let pipe = Pipe()
        whichProcess.standardOutput = pipe
        whichProcess.standardError = pipe
        
        try whichProcess.run()
        whichProcess.waitUntilExit()
        
        if whichProcess.terminationStatus != 0 {
            throw XcodegenError.notInstalled
        }
        
        // Run xcodegen
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", "cd \(directory) && xcodegen generate --spec project.yml"]
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            let outputData = try outputPipe.fileHandleForReading.readToEnd() ?? Data()
            let output = String(data: outputData, encoding: .utf8) ?? ""
            throw XcodegenError.generationFailed(output)
        }
    }
}

enum XcodegenError: Error {
    case notInstalled
    case generationFailed(String)
    
    var localizedDescription: String {
        switch self {
        case .notInstalled:
            return "xcodegen is not installed. Please install it using: brew install xcodegen"
        case .generationFailed(let output):
            return "Failed to generate Xcode project: \(output)"
        }
    }
} 
