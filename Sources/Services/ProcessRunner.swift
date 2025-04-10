import Foundation

protocol ProcessRunning {
    func run(_ process: Process) throws
}

struct ProcessRunner: ProcessRunning {
    func run(_ process: Process) throws {
        try process.run()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else {
            throw XcodegenError.generationFailed("Process exited with status \(process.terminationStatus)")
        }
    }
} 