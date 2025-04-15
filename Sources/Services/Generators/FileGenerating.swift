/// A protocol to define file-generation tasks.
protocol FileGenerating {
    func generateFiles(for configuration: ProjectConfiguration) throws
}
