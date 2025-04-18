import Foundation

enum OpenAIError: Error {
    case invalidResponse
    case decodingError
}

/// A client for interacting with the OpenAI API.
struct OpenAIClient {
    private static let apiKey = ""
    
    static func fetchResponse(
        for prompt: Prompt,
        withSystemPrompt systemPrompt: Prompt
    ) async throws -> String {
        let baseUrl = URL(string: "https://api.openai.com/v1/responses")!
        var request = URLRequest(url: baseUrl)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        let encoded = try Self.encoder.encode(OpenAIRequest(
            model: "gpt-4.1",
            input: [
                MessageRequest(role: "system",
                               content: [ContentRequest(type: "input_text",
                                                        text: systemPrompt.description)]),
                MessageRequest(role: "user",
                               content: [ContentRequest(type: "input_text",
                                                        text: prompt.description)]),
            ],
            temperature: 1.0,
            maxOutputTokens: 10_240,
            topP: 1.0
        ))
        request.httpBody = encoded
        request.timeoutInterval = 300
        
        // Start a loading spinner in the CLI
        let spinnerTask = Task {
            let spinnerSymbols = ["|", "/", "-", "\\"]
            let startTime = SuspendingClock.now
            var index = 0
            while !Task.isCancelled {
                let elapsed = startTime.duration(to: .now)
                print("\r\(spinnerSymbols[index % spinnerSymbols.count]) Generating boilerplate: \(elapsed) seconds", terminator: "")
                fflush(stdout)
                try? await Task.sleep(for: .seconds(0.2))
                index += 1
            }
        }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        spinnerTask.cancel()
        print("\r", terminator: "")
        
        print("Response Data: \(String(data: data, encoding: .utf8) ?? "")")
        
        guard let message = try JSONDecoder()
            .decode(OpenAIResponse.self, from: data)
            .output.first?.content.first?.text
        else { throw OpenAIError.invalidResponse }
        
        return message
    }
    
    static func fetchMockResponse(
        for prompt: Prompt,
        withSystemPrompt systemPrompt: Prompt
    ) async throws -> [String: String] {
        let url = Bundle.module.url(forResource: "Mock", withExtension: "json")!
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode([String: String].self, from: data)
        return response
    }
}

private extension OpenAIClient {
    static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}

private struct OpenAIResponse: Decodable {
    let output: [MessageResponse]
}

private struct MessageResponse: Decodable {
    let content: [ContentResponse]
}

private struct ContentResponse: Decodable {
    let type: String
    let text: String
}

private struct OpenAIRequest: Encodable {
    let model: String
    let input: [MessageRequest]
    let temperature: Double
    let maxOutputTokens: Int
    let topP: Double
}

private struct MessageRequest: Encodable {
    let role: String
    let content: [ContentRequest]
}

private struct ContentRequest: Encodable {
    let type: String
    let text: String
}
