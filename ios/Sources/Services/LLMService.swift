import Foundation

actor LLMService {
    private let mockResponses = [
        "好的，我已经记下了。",
        "有意思，请继续说。",
        "我明白你的意思了。",
        "这个问题很有趣，让我思考一下。",
        "你可以试着这样做。",
        "嗯，我理解你的需求。",
        "让我来帮你分析一下这个问题。",
    ]

    func send(messages: [Message], config: LLMConfig) async -> String {
        if config.provider == "mock" {
            try? await Task.sleep(nanoseconds: UInt64.random(in: 800_000_000...1_500_000_000))
            return mockResponses.randomElement() ?? "你好"
        }

        // Ollama path
        do {
            let url = URL(string: "\(config.ollamaUrl)/api/chat")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body: [String: Any] = [
                "model": config.model,
                "messages": messages.map { ["role": $0.role.rawValue, "content": $0.content] }
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return "抱歉，LLM 服务暂时不可用。"
            }

            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = json["message"] as? [String: Any],
               let content = message["content"] as? String {
                return content
            }
            return "（无回复）"
        } catch {
            return "抱歉，LLM 服务暂时不可用。"
        }
    }
}
