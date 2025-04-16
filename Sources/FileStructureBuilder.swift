import Foundation

protocol ProjectItem { }

enum MimeType: String {
    case swift
    case plist
    case yaml
}

struct Project {
    @FileStructureBuilder var body: () -> [ProjectItem]
}

struct File: ProjectItem {
    let name: String
    let path: String
    let mimeType: MimeType
    
    init(_ name: String, path: String, mimeType: MimeType) {
        self.name = name
        self.path = path
        self.mimeType = mimeType
    }
}

struct Folder: ProjectItem {
    let name: String
    let path: String
    @FileStructureBuilder let subStructure: () -> [ProjectItem]
}

@resultBuilder
struct FileStructureBuilder {
    static func buildBlock(_ components: ProjectItem...) -> [ProjectItem] {
        components
    }
    static func buildOptional(_ component: [ProjectItem]?) -> [ProjectItem] {
        component ?? []
    }
    static func buildEither(first component: [ProjectItem]) -> [ProjectItem] {
        component
    }
    static func buildEither(second component: [ProjectItem]) -> [ProjectItem] {
        component
    }
    static func buildArray(_ components: [[ProjectItem]]) -> [ProjectItem] {
        components.flatMap { $0 }
    }
}
