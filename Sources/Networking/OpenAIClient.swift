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
        request.httpBody = try Self.encoder.encode(OpenAIRequest(
            model: "gpt-4.1",
            input: [
                MessageRequest(role: "system",
                               content: ContentRequest(type: "input_text",
                                                       text: systemPrompt.description)),
                MessageRequest(role: "user",
                               content: ContentRequest(type: "input_text",
                                                       text: prompt.description)),
            ],
            temperature: 1.0,
            maxOutputTokens: 2048,
            topP: 1.0
        ))
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let message = try JSONDecoder()
            .decode(OpenAIResponse.self, from: data)
            .output.first?.content.first?.text
        else { throw OpenAIError.invalidResponse }
        
        return message
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
    let content: ContentRequest
}

private struct ContentRequest: Encodable {
    let type: String
    let text: String
}
