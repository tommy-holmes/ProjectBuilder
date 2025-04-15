/// A protocol for any component that contributes to file generation.
protocol ComponentGenerator {
    func generate(with context: inout GenerationContext) throws
}
