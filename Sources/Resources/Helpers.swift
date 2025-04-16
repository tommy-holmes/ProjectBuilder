import Foundation

struct Helpers {
    static func createFile(at path: String, with content: String) throws {
        let fileURL = URL(fileURLWithPath: path)
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
    }
}
